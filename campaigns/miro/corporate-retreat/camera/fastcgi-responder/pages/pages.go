package pages

import (
	. "maragu.dev/gomponents"
	. "maragu.dev/gomponents/components"
	. "maragu.dev/gomponents/html"
	"net/http"
)

func Page(w http.ResponseWriter, content Node, scripts ...Node) {
	err := HTML5(HTML5Props{
		Title:    "Internet Home Monitoring Camera",
		Language: "en",
		Head: []Node{
			Meta(Charset("utf-8")),
			Meta(Name("viewport"), Content("width=device-width, initial-scale=1")),
			Link(Rel("stylesheet"), Href("style.css")),
		},
		Body: []Node{
			Div(
				append([]Node{
					Header(
						H1(Raw("Internet Camera &reg;")),
						Raw("<marquee>IVC60N-PLUS internet camera | IVC-OS 1.5.9 build 551916735aeecf1474109865fda11948173d76b1a705293de527130b8dc7271b | MVIC LLC. ALL RIGHTS RESERVED |</marquee>"),
						Table(
							Td(A(Class("link"), Href("/"), Text("Home"))),
							Td(A(Class("link"), Href("/video"), Text("Image Feed"))),
							Td(A(Class("link"), Href("/admin"), Text("Admin settings"))),
						)),
					Main(content),
					Footer(
						Raw("&copy; 2005&ndash;2009 "),
						A(
							Href("https://www.mightiest-video-internet-cameraas.com/"),
							Text("MVIC LL.C.,")),
						Text(" All Rights reserved.")),
				}, scripts...)...,
			),
		},
	}).Render(w)

	if err != nil {
		w.WriteHeader(500)
		w.Write([]byte("Internal Server Error"))
		return
	}

}
