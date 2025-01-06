package org.example.loginserver;

import at.favre.lib.crypto.bcrypt.BCrypt;
import com.auth0.jwt.JWT;
import com.auth0.jwt.algorithms.Algorithm;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.time.temporal.ChronoUnit;

@Service
public class AuthService {
	private final String secret;
	private final AuthDao authDao;
	private static final byte[] SALT = new byte[] { -13, 23, -113, 127, -23, 97, -106, 24, -85, -83, -51, -41, -86, -84, -11, 22 };

	@Autowired
	public AuthService(@Value("${authus.jwt.secret}") String secret, AuthDao authDao) {
		this.secret = secret;
		this.authDao = authDao;
	}

	public boolean verifyCredentials(String username, String password) {
		byte[] hash = BCrypt.withDefaults().hash(14, SALT, password.getBytes(StandardCharsets.UTF_8));
		return authDao.verifyCredentials(username, new String(hash));
	}

	public String issueJWT(String username) {
		return JWT.create()
			.withIssuedAt(Instant.now())
			.withSubject(username)
			.withExpiresAt(Instant.now().plus(8, ChronoUnit.HOURS))
			.sign(Algorithm.HMAC256(secret));
	}
}
