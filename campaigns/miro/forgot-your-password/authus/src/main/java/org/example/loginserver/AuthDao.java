package org.example.loginserver;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.sql.*;

@Component
public class AuthDao {
	private final Connection connection;

	@Autowired
	public AuthDao(@Value("${authus.db.url}") String jdbcUrl) throws SQLException {
		connection = DriverManager.getConnection(jdbcUrl);
	}

	public boolean verifyCredentials(String username, String passwordHash) {
		try {
			PreparedStatement statement = connection.prepareStatement("select * from auth_attempt(?, ?)");
			statement.setString(1, username);
			statement.setString(2, passwordHash);
			ResultSet resultSet = statement.executeQuery();
			resultSet.next();
			return resultSet.getBoolean(1);
		} catch (SQLException ignored) {
			return false;
		}
	}
}
