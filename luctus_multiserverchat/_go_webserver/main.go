package main

import (
	"flag"
	"fmt"
	"github.com/gorilla/websocket"
	"log/slog"
	"net/http"
	"os"
	"strconv"
	"sync"
)

var connectionPool = struct {
	sync.RWMutex
	connections map[*websocket.Conn]struct{}
}{
	connections: make(map[*websocket.Conn]struct{}),
}

var port = flag.Int("port", 3002, "port to listen on")
var ip = flag.String("ip", "0.0.0.0", "ip to listen on")
var log = flag.String("log", "msc.log", "where to log to")

func main() {
	flag.Parse()
	// Logging
	f, err := os.OpenFile(*log, os.O_WRONLY|os.O_CREATE|os.O_APPEND, 0644)
	if err != nil {
		panic(err)
	}
	defer f.Close()
	logger := slog.New(slog.NewTextHandler(f, nil))
	// Webserver
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		fmt.Fprint(w, "OK")
		return
	})
	http.HandleFunc("/test", func(w http.ResponseWriter, r *http.Request) {
		sendMessageToAllPool("INFO [LUCTUS_MSC] TEST MESSAGE", logger)
	})
	http.HandleFunc("/ws", func(w http.ResponseWriter, r *http.Request) {
		err := wshandler(w, r, logger)
		if err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			fmt.Fprint(w, err.Error())
			return
		}
	})
	logger.Info("Starter service")
	err = http.ListenAndServe(*ip+":"+strconv.Itoa(*port), nil)
	if err != nil {
		panic(err)
	}
}

var wsupgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
}

func wshandler(w http.ResponseWriter, r *http.Request, logger *slog.Logger) error {
	conn, err := wsupgrader.Upgrade(w, r, nil)
	if err != nil {
		logger.Error("error during ws upgrade", "err", err)
		return err
	}

	connectionPool.Lock()
	connectionPool.connections[conn] = struct{}{}
	defer func(connection *websocket.Conn) {
		connectionPool.Lock()
		delete(connectionPool.connections, connection)
		connectionPool.Unlock()
		logger.Info("listener removed", "remoteaddr", r.RemoteAddr)
	}(conn)
	connectionPool.Unlock()
	logger.Info("listener added", "remoteaddr", r.RemoteAddr)

	for {
		//t, msg, err := conn.ReadMessage()
		_, msg, err := conn.ReadMessage()
		if err != nil {
			logger.Error("error in for conn ReadMessage", "err", err)
			return err
		}
		//conn.WriteMessage(t, msg)
		logger.Info("message received, broadcasting", "remoteaddr", r.RemoteAddr, "msg", msg)
		sendMessageToAllPool(string(msg), logger)
	}
}

func sendMessageToAllPool(message string, logger *slog.Logger) {
	connectionPool.RLock()
	defer connectionPool.RUnlock()
	for connection := range connectionPool.connections {
		if err := connection.WriteMessage(websocket.TextMessage, []byte(message)); err != nil {
			logger.Error("error writing message to ws conn", "err", err, "remoteaddr", connection.RemoteAddr().String())
		}
	}
	return
}
