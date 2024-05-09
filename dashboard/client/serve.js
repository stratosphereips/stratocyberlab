#!/usr/bin/env node

const package = require("./package");
const clear = require("console-clear");
const laccess = require("local-access");
const path = require("path");
const sade = require("sade");

sade(path.basename(__filename) + " <serve_dir> <proxy_path> <proxy_url>", true)
  .version(package.version)
  .describe("Run a proxy in front of sirv")
  .example("public /api http://localhost:8080 --single --dev")
  .option("-D, --dev", 'Enable "dev" mode')
  .option(
    "-s, --single",
    'Serve as single-page application with "index.html" fallback'
  )
  .option("-p, --port", "Port to bind", 3000)
  .option("-c, --clear", "Clear screen before logging", true)
  .action(run)
  .parse(process.argv);

function run(serveDir, proxyPath, proxyUrl, opts) {
  const { createProxyMiddleware } = require("http-proxy-middleware");
  const font = require("kleur");
  const polka = require("polka");
  const sirv = require("sirv");
  const tinydate = require("tinydate");

  const { hrtime, stdout } = process;

  const format = {
    code: (c) => {
      let color = c >= 400 ? "red" : c > 300 ? "yellow" : "green";
      return font[color](c);
    },
    duration: (d) => font.white().bold((d[1] / 1e6).toFixed(2) + "ms"),
    now: tinydate("{HH}:{mm}:{ss}"),
    timestamp: (t) => "[" + font.magenta(t) + "]",
  };

  function logger(req, res, next) {
    const start = hrtime();
    req.once("end", () => {
      const duration = hrtime(start);
      const url = req.originalUrl || req.url;
      const line = [
        format.timestamp(format.now()),
        format.code(res.statusCode),
        font.gray("─"),
        format.duration(duration),
        font.gray("─"),
        url,
      ].join(" ");
      stdout.write(line + "\n");
    });
    next();
  }

  polka()
    .use(
      logger,
      createProxyMiddleware(proxyPath, {
        target: proxyUrl,
        changeOrigin: true,
      }),
      sirv(serveDir, { dev: opts.dev, single: opts.single })
    )
    .listen(opts.port, (error) => {
      if (error) throw error;
      const { local, network } = laccess({ port: opts.port });
      if (opts.clear === true) clear(true);
      stdout.write(`\n${font.green("Your application is ready~! 🚀")}\n\n`);
      stdout.write(`Proxy: ${proxyPath} → ${proxyUrl}\n\n`);
      stdout.write(`${font.bold("Local:")}   ${local}\n`);
      stdout.write(`${font.bold("Network:")} ${network}\n\n`);
    });
}
