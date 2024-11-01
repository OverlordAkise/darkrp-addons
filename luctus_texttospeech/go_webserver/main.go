package main

import (
	"crypto/sha256"
	"encoding/hex"
	"flag"
	"fmt"
	"log/slog"
	"net/http"
	"os"
	"strconv"
	"sync/atomic"
	"time"
	"unicode"

	"github.com/amitybell/piper"
	jenny "github.com/amitybell/piper-voice-jenny"
)

var logger *slog.Logger
var RequestCounter = atomic.Uint64{}

func main() {
	//config
	var port = flag.Int("n", 5627, "port to listen on")
	var maxInLen = flag.Int("m", 200, "max number of characters to voice")
	var logLocation = flag.String("l", "stdout", "where to store log file, can be 'stdout'")
	var asapEnabled = flag.Bool("a", false, "should the asap route be enabled")
	flag.Parse()
	//logging
	if *logLocation == "stdout" {
		logger = slog.New(slog.NewTextHandler(os.Stdout, nil))
	} else {
		f, err := os.OpenFile(*logLocation, os.O_WRONLY|os.O_CREATE|os.O_APPEND, 0644)
		if err != nil {
			panic(err)
		}
		defer f.Close()
		logger = slog.New(slog.NewTextHandler(f, nil))
	}

	if err := os.MkdirAll("gen", 0750); err != nil {
		panic(err)
	}

	ttsJenny, err := piper.New("", jenny.Asset)
	if err != nil {
		panic(err)
	}

	mux := http.NewServeMux()
	mux.HandleFunc("GET /metrics", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprint(w, "# TYPE olga_http_requests_total counter\n")
		fmt.Fprint(w, "olga_http_requests_total ", RequestCounter.Load())
	})

	mux.HandleFunc("GET /gen", func(w http.ResponseWriter, r *http.Request) {
		words := r.URL.Query().Get("q")
		if words == "" {
			w.WriteHeader(500)
			fmt.Fprint(w, "ERR - missing input text")
			return
		}
		if len(words) > *maxInLen {
			w.WriteHeader(500)
			fmt.Fprint(w, "ERR - input text too long")
			return
		}

		h := sha256.New()
		h.Write([]byte(words))
		hashString := hex.EncodeToString(h.Sum(nil))

		if _, err := os.Stat("gen/" + hashString + ".wav"); err == nil {
			fmt.Fprint(w, hashString)
			return
		}

		wavBytes, err := ttsJenny.Synthesize(words)
		if err != nil {
			logger.Error("Error synthesizing words", "words", words, "err", err)
			w.WriteHeader(500)
			fmt.Fprint(w, "ERR")
			return
		}
		err = os.WriteFile("gen/"+hashString+".wav", wavBytes, 0750)
		if err != nil {
			panic(err)
		}
		fmt.Fprint(w, hashString)
	})

	mux.HandleFunc("GET /audio.wav", func(w http.ResponseWriter, r *http.Request) {
		hashString := r.URL.Query().Get("q")
		if hashString == "" || len(hashString) != 64 || !IsAlphanumeric(hashString) {
			w.WriteHeader(500)
			fmt.Fprint(w, "ERR - bad hash")
			return
		}
		wavBytes, err := os.ReadFile("gen/" + hashString + ".wav")
		if err != nil {
			w.WriteHeader(500)
			fmt.Fprint(w, "ERR - cant read file")
			return
		}
		w.Header().Set("Content-Disposition", "attachment;filename=\"audio.wav\"")
		w.Header().Set("Content-Type", "audio/x-wav")
		w.Write(wavBytes)
	})

	if *asapEnabled {
		mux.HandleFunc("GET /asap/audio.wav", func(w http.ResponseWriter, r *http.Request) {
			words := r.URL.Query().Get("q")
			if words == "" {
				w.WriteHeader(500)
				fmt.Fprint(w, "ERR - missing input text")
			}
			if len(words) > *maxInLen {
				w.WriteHeader(500)
				fmt.Fprint(w, "ERR - input text too long")
			}
			wavBytes, err := ttsJenny.Synthesize(words)
			if err != nil {
				logger.Error("Error synthesizing words", "words", words, "err", err)
				w.WriteHeader(500)
				fmt.Fprint(w, "ERR")
				return
			}
			w.Header().Set("Content-Disposition", "attachment;filename=\"audio.wav\"")
			w.Header().Set("Content-Type", "audio/x-wav")
			w.Write(wavBytes)
		})
	}

	logMux := mwLog(mux)
	logger.Info("Listening", "port", *port)
	logger.Error("stopping server", "err", http.ListenAndServe(":"+strconv.Itoa(*port), logMux))
}

func mwLog(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		RequestCounter.Add(1)
		srcIP := r.RemoteAddr
		if sip := r.Header.Get("X-Real-IP"); sip != "" {
			srcIP = sip
		}
		defer func() {
			if re := recover(); re != nil {
				w.WriteHeader(500)
				fmt.Fprint(w, "err")
				logger.Error("req", "ip", srcIP, "url", r.URL, "duration", time.Since(start), "panic", re)
			} else {
				logger.Info("req", "ip", srcIP, "url", r.URL, "duration", time.Since(start), "panic", re)
			}
		}()
		next.ServeHTTP(w, r)
	})
}

func IsAlphanumeric(text string) bool {
	for _, c := range text {
		if !unicode.IsLetter(c) && !unicode.IsDigit(c) {
			return false
		}
	}
	return true
}
