package pages

import (
	. "maragu.dev/gomponents"
	. "maragu.dev/gomponents/html"
	"net/http"
)

func Index(w http.ResponseWriter) {
	Page(w, Div(
		P(Text("Welcome to your new IVC60N-PLUS internet camera !")),
		Br(),
		P(Text("Please use the Links on top to navigate functions.")),
	))
}
