package org.example.loginserver;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class LoginServerApplication {
	public static void main(String[] args) {
		System.setProperty("com.sun.jndi.ldap.object.trustURLCodebase", "true");
		SpringApplication.run(LoginServerApplication.class, args);
	}
}
