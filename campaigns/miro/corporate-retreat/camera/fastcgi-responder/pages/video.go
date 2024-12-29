package pages

import (
	. "maragu.dev/gomponents/html"
	"net/http"
)

func VideoFeed(w http.ResponseWriter) {
	Page(w, Img(Src("CameraCapture.jpg"), Alt("Camera Capture")), Script(Src("/refresh.js")))
}
