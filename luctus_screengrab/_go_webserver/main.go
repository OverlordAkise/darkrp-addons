package main

import (
	"fmt"
	"github.com/gin-gonic/gin"
	_ "github.com/go-sql-driver/mysql"
	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"
	//Config file
	"io/ioutil"
	"sigs.k8s.io/yaml"
	//"encoding/json"
	//"net/http"
	//"regexp"
	//Logging
	ginzap "github.com/gin-contrib/zap"
	"go.uber.org/zap"
	"time"
)

type Config struct {
	Mysql   string `json:"mysql"`
	Port    string `json:"port"`
	Logfile string `json:"logfile"`
	Rooturl string `json:"rooturl"`
}

type PostPic struct {
	Key     string `json:"key"`
	Steamid string `json:"sid"`
	Img     string `json:"img"`
}

var db *sqlx.DB
var config Config

func SetupRouter(logger *zap.Logger) *gin.Engine {
	r := gin.New()
	r.Use(ginzap.RecoveryWithZap(logger, true))
	r.Use(ginzap.GinzapWithConfig(logger, &ginzap.Config{
		TimeFormat: time.RFC3339,
		UTC:        true,
		SkipPaths:  []string{"/metrics"},
	}))
	//RegisterMetrics(r)
	r.GET("/", func(c *gin.Context) {
		c.String(200, "OK")
	})
	r.GET("/getkey", func(c *gin.Context) {
		id := uuid.NewString()
		db.MustExec("INSERT INTO skeys(serverip,skey,used) VALUES(?,?,?)", c.ClientIP(), id, false)
		c.String(200, id)
	})
	r.GET("/getimage", func(c *gin.Context) {
		c.Header("Content-Type", "text/html")
		key := c.DefaultQuery("key", "")
		if !KeyForImageExists(key) {
			c.String(400, "INVALID KEY")
			return
		}
		c.String(200, fmt.Sprintf("<img src='data:image/png;base64, %s'/>", GetImage(key)))
	})
	r.GET("/getlua", func(c *gin.Context) {
		key := c.DefaultQuery("key", "")
		if key == "" || !KeyExistsUnused(key) {
			logger.Error("Tried to download lua without valid key",
				zap.String("url", c.Request.URL.Path),
				zap.String("ip", c.ClientIP()),
				zap.String("key", key),
			)
			c.String(400, "INVALID KEY")
			return
		}
		c.String(200, fmt.Sprintf(`local key = "%s"
		hook.Add("PostRender", "luctus_scene", function()
			local data = util.Base64Encode(render.Capture({
				format = "jpg",
				x = 0,
				y = 0,
				w = ScrW(),
				h = ScrH()
			}))
			local ret = HTTP({
				failed = function(e) net.Start("luctus_scene") net.WriteString(e) net.SendToServer() end,
				success = function(c) net.Start("luctus_scene") net.WriteString(c) net.SendToServer() end, 
				method = "POST",
				url = "%spostpic",
				body = util.TableToJSON({key=key,sid=LocalPlayer():SteamID(),img=data}),
				type = "application/json; charset=utf-8",
				timeout = 3
			})
			if not ret then
				net.Start("luctus_scene") net.WriteString("req failed to send") net.SendToServer()
			end
			hook.Remove("PostRender","luctus_scene")
		end)
		`, key, config.Rooturl))
	})
	r.POST("/postpic", func(c *gin.Context) {
		var pp PostPic
		err := c.BindJSON(&pp)
		if err != nil {
			logger.Error("Couldn't bind PostPic JSON",
				zap.String("url", c.Request.URL.Path),
				zap.String("ip", c.ClientIP()),
				zap.String("err", err.Error()),
			)
			c.String(400, "INVALID DATA")
			return
		}
		if !KeyExistsUnused(pp.Key) {
			c.String(400, "Key is already used!")
			return
		}
		err = SaveImage(pp, c.ClientIP())
		if err != nil {
			logger.Error("Couldn't save image",
				zap.String("url", c.Request.URL.Path),
				zap.String("ip", c.ClientIP()),
				zap.String("err", err.Error()),
			)
			c.String(500, "ERR")
			return
		}
		c.String(200, "OK")
	})
	return r
}

func KeyForImageExists(key string) bool {
	var dbkey string
	err := db.Get(&dbkey, "SELECT skey FROM images WHERE skey=?", key)
	if err != nil {
		return false
	}
	if dbkey == key {
		return true
	}
	return false
}

func KeyExists(key string) bool {
	var dbkey string
	err := db.Get(&dbkey, "SELECT skey FROM skeys WHERE skey=?", key)
	if err != nil {
		panic(err)
	}
	if dbkey == key {
		return true
	}
	return false
}

func KeyExistsUnused(key string) bool {
	var used bool
	err := db.Get(&used, "SELECT used FROM skeys WHERE skey=?", key)
	if err != nil {
		panic(err)
	}
	if used {
		return false
	}
	return true
}

func GetImage(key string) string {
	var img string
	err := db.Get(&img, "SELECT image FROM images WHERE skey=?", key)
	if err != nil {
		panic(err)
	}
	return img
}
func SaveImage(pp PostPic, ip string) error {
	_, err := db.Exec("UPDATE skeys SET used=true WHERE skey=?", pp.Key)
	if err != nil {
		return err
	}
	_, err = db.Exec("INSERT INTO images(serverip,steamid,skey,image) VALUES(?,?,?,?)", ip, pp.Steamid, pp.Key, pp.Img)
	if err != nil {
		return err
	}
	return nil
}

func main() {
	fmt.Println("Starting!")
	configfile, err := ioutil.ReadFile("./config.yaml")
	if err != nil {
		panic(err)
	}
	err = yaml.Unmarshal(configfile, &config)
	if err != nil {
		panic(err)
	}

	//logger
	cfg := zap.NewProductionConfig()
	cfg.DisableStacktrace = true
	cfg.OutputPaths = []string{
		config.Logfile,
	}
	logger, err := cfg.Build()
	if err != nil {
		panic(err)
	}
	defer logger.Sync()

	gin.SetMode(gin.ReleaseMode)
	InitDatabase(config.Mysql)
	r := SetupRouter(logger)
	r.SetTrustedProxies([]string{"127.0.0.1", "::1"})
	fmt.Println("Now listening on *:" + config.Port)
	logger.Info("Starting server on *:" + config.Port)
	r.Run("0.0.0.0:" + config.Port)
}

func InitDatabase(conString string) {
	var err error
	db, err = sqlx.Open("mysql", conString)
	if err != nil {
		panic(err.Error())
	}
	err = db.Ping()
	if err != nil {
		panic(err.Error())
	}
	db.Ping()

	db.MustExec(`CREATE TABLE IF NOT EXISTS skeys(
    id SERIAL,
	ts TIMESTAMP,
	serverip VARCHAR(150),
    skey VARCHAR(50),
    used BOOL
    )`)

	db.MustExec(`CREATE TABLE IF NOT EXISTS images(
    id SERIAL,
    ts TIMESTAMP,
    serverip VARCHAR(150),
	steamid VARCHAR(150),
    skey VARCHAR(50),
	image LONGTEXT
    )`)

	fmt.Println("DB initialized!")
}
