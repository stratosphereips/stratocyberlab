package main

import (
	"fmt"
	"net"
	"net/http"
	"net/http/fcgi"
	"os"
	. "responder/pages"
)

type FastCGIServer struct{}

func (s FastCGIServer) ServeHTTP(w http.ResponseWriter, req *http.Request) {
	switch req.URL.Path {
	case "/":
		Index(w)
	case "/video":
		VideoFeed(w)
	case "/admin":
		if req.Method == "GET" {
			AdminForm(w)
		} else if req.Method == http.MethodPut {
			cookie, _ := req.Cookie("credentials")
			if cookie == nil || cookie.Value != "admin:GIWz8DQjXdi4gmId3G8yPHRc" {
				w.Header().Set("Location", "/admin")
				w.WriteHeader(302)
				return
			}
			// TODO save values
			w.WriteHeader(204)
			w.Write([]byte(""))
		} else {
			w.WriteHeader(405)
			w.Write([]byte("Method Not Allowed\n"))
		}
	case "/CameraCapture.jpg":
		file, err := os.ReadFile("/etc/lighttpd/office.jpg")
		if err != nil {
			w.WriteHeader(500)
			w.Write([]byte("Internal Server Error\n"))
			return
		}
		// TODO modify the image based on time of day + config
		w.Write(file)
	default:
		w.WriteHeader(404)
		w.Write([]byte("Page Not Found\n"))
	}
}

func main() {
	fmt.Println("Starting server...")
	l, _ := net.Listen("tcp", "127.0.0.1:9000")
	b := new(FastCGIServer)
	fcgi.Serve(l, b)
}
