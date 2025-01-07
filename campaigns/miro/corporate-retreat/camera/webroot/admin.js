document.getElementById("auth-form").addEventListener("submit", function (ev) {
  ev.preventDefault();

  var username = document.getElementById("username").value;
  var password = document.getElementById("password").value;

  if (
    username != "admin" ||
    atob(
      atob(
        "=0TSG10coZlWxh2VSZFZGNmWwFjUyJkaXlXRqNVYStGVJlTRTNnRxU1RwtWY"
          .split("")
          .reverse()
          .join(""),
      ),
    ) != btoa(password).split("").reverse().join("")
  ) {
    confirm("Wrong password, please try again");
    return;
  }

  document.cookie = "credentials=admin:GIWz8DQjXdi4gmId3G8yPHRc; Path=/;";

  for (var i = 0; i < ev.target.parentElement.children.length; i++) {
    ev.target.parentElement.children[i].className = "";
  }

  ev.target.outerHTML = "";
});

document.getElementById("execute").addEventListener("click", function () {
  var xhr = new XMLHttpRequest();
  xhr.open("POST", "/shell");

  xhr.onload = function () {
    document.getElementById("prompt").value = "";
    document.getElementById("terminal").innerText = xhr.responseText;
  };
  xhr.send(document.getElementById("prompt").value);
});
