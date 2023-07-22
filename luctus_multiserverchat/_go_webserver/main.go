package main

import (
	"fmt"
	"github.com/gin-gonic/gin"
	"github.com/gorilla/websocket"
	"net/http"
	"strconv"
	"sync"
)

var connectionPool = struct {
	sync.RWMutex
	connections map[*websocket.Conn]struct{}
}{
	connections: make(map[*websocket.Conn]struct{}),
}

func main() {
	r := gin.Default()

	r.GET("/test", func(c *gin.Context) {
		sendMessageToAllPool("INFO [LUCTUS_MSC] TEST MESSAGE")
	})
	r.GET("/ws", func(c *gin.Context) {
		wshandler(c.Writer, c.Request)
	})

	fmt.Println("[LUCTUS_MSC] Listening...")
	r.Run(":3002")
}

var wsupgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
}

func wshandler(w http.ResponseWriter, r *http.Request) {
	conn, err := wsupgrader.Upgrade(w, r, nil)
	if err != nil {
		fmt.Println("[WS] ERROR:", err)
		return
	}

	connectionPool.Lock()
	connectionPool.connections[conn] = struct{}{}
	defer func(connection *websocket.Conn) {
		connectionPool.Lock()
		delete(connectionPool.connections, connection)
		connectionPool.Unlock()
		sendMessageToAllPool("INFO [LUCTUS_MSC] Removed listener")
	}(conn)
	connectionPool.Unlock()
	sendMessageToAllPool("INFO [LUCTUS_MSC] New listener")
	sendMessageToAllPool("INFO [LUCTUS_MSC] Current listeners: " + strconv.Itoa(len(connectionPool.connections)))

	for {
		//t, msg, err := conn.ReadMessage()
		_, msg, err := conn.ReadMessage()
		if err != nil {
			break
		}
		//conn.WriteMessage(t, msg)
		sendMessageToAllPool(string(msg))
	}
}

func sendMessageToAllPool(message string) error {
	fmt.Println("[WS] Sending:", message)
	connectionPool.RLock()
	defer connectionPool.RUnlock()
	for connection := range connectionPool.connections {
		if err := connection.WriteMessage(websocket.TextMessage, []byte(message)); err != nil {
			return err
		}
	}
	return nil
}
