package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net"
	"net/http"
	"net/http/fcgi"
	"os"
	"os/exec"
	. "responder/pages"
	"strings"
)

type FastCGIServer struct{}

func SaveSettings(settings Settings) bool {
	jsonStr, err := json.Marshal(settings)
	if err != nil {
		log.Fatal(err)
		return false
	}

	err = os.WriteFile("/var/www/settings.json", jsonStr, 0644)
	if err != nil {
		log.Fatal(err)
	}
	return err == nil
}

func LoadSettings() (Settings, error) {
	settings := &Settings{}
	file, err := os.ReadFile("/var/www/settings.json")
	if err != nil {
		return *settings, err
	}
	err = json.Unmarshal(file, settings)
	if err != nil {
		return *settings, err
	}

	return *settings, nil
}

func (s FastCGIServer) ServeHTTP(w http.ResponseWriter, req *http.Request) {
	switch req.URL.Path {
	case "/":
		Index(w)
	case "/video":
		VideoFeed(w)
	case "/admin":
		if req.Method == "GET" {
			settings, err := LoadSettings()
			if err != nil {
				w.WriteHeader(500)
				w.Write([]byte("Internal Server Error\n"))
				return
			}
			AdminForm(w, settings)
		} else if req.Method == http.MethodPost {
			if !auth(req, w) {
				return
			}
			err := req.ParseForm()
			if err != nil {
				log.Fatal(err)
				return
			}
			log.Println(req.Form)
			settings := Settings{
				Timezone: req.FormValue("timezone"),
			}
			if SaveSettings(settings) {
				w.WriteHeader(302)
				w.Header().Set("Location", "/admin")
				w.Write([]byte(""))
			} else {
				w.WriteHeader(500)
				w.Write([]byte("Internal Server Error\n"))
			}
		} else {
			w.WriteHeader(405)
			w.Write([]byte("Method Not Allowed\n"))
		}
	case "/shell":
		if req.Method != http.MethodPost {
			w.WriteHeader(405)
			w.Write([]byte("Method Not Allowed\n"))
			return
		}
		if !auth(req, w) {
			return
		}
		body, err := ioutil.ReadAll(req.Body)
		if err != nil {
			w.WriteHeader(400)
			w.Write([]byte("Bad Request\n"))
			return
		}
		split := strings.Split(string(body), " ")
		cmd := exec.Command(split[0], append([]string{}, split[1:]...)...)
		output, err := cmd.CombinedOutput()
		if err != nil {
			w.WriteHeader(500)
		}
		w.Write(output)
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

func auth(req *http.Request, w http.ResponseWriter) bool {
	cookie, _ := req.Cookie("credentials")
	if cookie == nil || cookie.Value != "admin:GIWz8DQjXdi4gmId3G8yPHRc" {
		w.Header().Set("Location", "/admin")
		w.WriteHeader(302)
		return false
	}
	return true
}

func main() {
	fmt.Println("Starting server...")
	l, _ := net.Listen("tcp", "127.0.0.1:9000")
	b := new(FastCGIServer)
	fcgi.Serve(l, b)
}
