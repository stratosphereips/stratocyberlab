package org.example.loginserver;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.*;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;

import java.net.URI;

@Controller
@RequestMapping("/auth")
public class AuthController {
	private static final Logger logger = LogManager.getLogger(AuthController.class);

	private final AuthService authService;

	@Autowired
	public AuthController(AuthService authService) {
		this.authService = authService;
	}

	@GetMapping("/login")
	public String loginForm(@RequestParam(value = "error", required = false) Boolean error, Model model) {
		model.addAttribute("error", error);
		return "form.html";
	}

	@RequestMapping(value = "/login", method = RequestMethod.POST)
	public ResponseEntity<String> processLogin(
		@RequestParam("username") String username,
		@RequestParam("password") String password
	) {
		if (!authService.verifyCredentials(username, password)) {
			logger.warn("Failed login attempt for user {} {}", username, password);
			return ResponseEntity
				.status(HttpStatus.FOUND)
				.location(URI.create("/auth/login?error=true"))
				.build();
		}

		String jwt = authService.issueJWT(username);
		HttpCookie cookie = ResponseCookie
			.from("jwt", jwt)
			.path("/")
			.httpOnly(true)
			.build();

		return ResponseEntity
			.status(HttpStatus.FOUND)
			.header(HttpHeaders.SET_COOKIE, cookie.toString())
			.location(URI.create("/dashboard"))
			.build();
	}
}

