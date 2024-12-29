package pages

import (
	. "maragu.dev/gomponents"
	. "maragu.dev/gomponents/html"
	"net/http"
)

func TextInput(id string, attrs ...Node) Node {
	return Input(append([]Node{
		Type("text"),
		Name(id),
		ID(id),
		AutoComplete("off"),
	}, attrs...,
	)...)
}

func Field(label string, id string, input Node) Node {
	return Tr(
		Td(Label(For(id), Text(label))),
		Td(input),
	)
}

// dumped from `ls /usr/share/zoneinfo/Etc`, only including GMT with offset
var tzs = []string{
	"GMT+0",
	"GMT+1",
	"GMT+10",
	"GMT+11",
	"GMT+12",
	"GMT+2",
	"GMT+3",
	"GMT+4",
	"GMT+5",
	"GMT+6",
	"GMT+7",
	"GMT+8",
	"GMT+9",
	"GMT-1",
	"GMT-10",
	"GMT-11",
	"GMT-12",
	"GMT-13",
	"GMT-14",
	"GMT-2",
	"GMT-3",
	"GMT-4",
	"GMT-5",
	"GMT-6",
	"GMT-7",
	"GMT-8",
	"GMT-9",
}

func AdminForm(w http.ResponseWriter, settings Settings) {
	Page(w, Div(
		Form(
			ID("auth-form"),
			H2(Text("Admin Login")),
			Table(
				Field("Username", "username", TextInput("username")),
				Field("Password", "password", TextInput("password", Type("password"))),
				Tr(Td(ColSpan("2"), Input(Type("submit"), Value("Log in")))),
			),
		),
		Form(
			Class("hidden"),
			Method("POST"),
			Action(""),
			H2(Text("Settings")),
			Div(
				H3(Text("General")),
				Table(
					Field("Time zone", "timezone",
						SelectWithValue("timezone", tzs, settings.Timezone),
					),
					Tr(Td(ColSpan("2"), Input(Type("submit"), Value("Save and restart")))),
				),
			),
		),
		Section(
			Class("hidden"),
			H3(Text("Shell")),
			P(Text("WARNING! This is a administrator shell, please do not use it unless you know EXACTLY what you're doing - incorrect use can cause irreversible damage to the device!!!")),
			Textarea(ID("prompt")),
			Button(Text("Run"), ID("execute")),
			Pre(ID("terminal")),
		),
	), Script(Src("admin.js")))
}

func SelectWithValue(id string, options []string, value string) Node {
	children := make([]Node, len(options)+1)
	children = append(children, ID(id))
	for i := range options {
		attrs := []Node{
			Value(options[i]),
			Text(options[i]),
		}
		if value == options[i] {
			attrs = append(attrs, Selected())
		}
		children[i+1] = Option(attrs...)
	}
	return Select(append([]Node{ID(id), Name(id)}, children...)...)
}

type Settings struct {
	Timezone string
}
