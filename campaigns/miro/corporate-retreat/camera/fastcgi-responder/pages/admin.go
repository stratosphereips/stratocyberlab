package pages

import (
	. "maragu.dev/gomponents"
	. "maragu.dev/gomponents/html"
	"net/http"
)

func AdminForm(w http.ResponseWriter) {
	Page(w, Form(
		ID("auth-form"), Table(
			Tr(
				Td(Label(For("username"), Text("Username"))),
				Td(Input(Type("text"), Name("username"), AutoComplete("off"), ID("username"))),
			),
			Tr(
				Td(Label(For("password"), Text("Password"))),
				Td(Input(Type("password"), Name("password"), AutoComplete("off"), ID("password"))),
			),
			Tr(
				Td(ColSpan("2"), Input(Type("submit"), Value("Log in"))),
			),
		),
	), Script(Src("admin.js")))
}
