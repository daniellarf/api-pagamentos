const http = require("http");
const fs = require("fs");
const path = require("path");

const port = Number(process.env.DTRACK_MOCK_PORT || 8081);
const logDir = path.resolve("evidence");
const logFile = path.join(logDir, "dependency-track-server.log");

fs.mkdirSync(logDir, { recursive: true });

const server = http.createServer((req, res) => {
  if (req.method !== "POST" || req.url !== "/api/v1/bom") {
    res.writeHead(404, { "Content-Type": "application/json" });
    return res.end(JSON.stringify({ error: "not_found" }));
  }

  let body = "";
  req.setEncoding("utf8");
  req.on("data", (chunk) => {
    body += chunk;
  });

  req.on("end", () => {
    const record = {
      timestamp: new Date().toISOString(),
      method: req.method,
      path: req.url,
      contentType: req.headers["content-type"],
      bytesReceived: Buffer.byteLength(body),
      token: "mock-" + Date.now()
    };

    fs.appendFileSync(logFile, JSON.stringify(record) + "\n");

    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(JSON.stringify({
      token: record.token,
      status: "accepted",
      mode: "mock"
    }));
  });
});

server.listen(port, () => {
  console.log(`Dependency-Track mock em http://localhost:${port}`);
  console.log(`Endpoint: POST /api/v1/bom`);
  console.log(`Log: ${logFile}`);
});
