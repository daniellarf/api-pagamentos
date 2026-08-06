const fs = require("fs");
const path = require("path");
const http = require("http");

const sbomPath = process.argv[2] || "sbom/sbom-cyclonedx.json";
const outputPath = process.argv[3] || "evidence/dependency-track-api.log";
const endpoint = new URL(
  process.env.DTRACK_URL || "http://localhost:8081/api/v1/bom"
);

try {
  const sbom = fs.readFileSync(sbomPath, "utf8");
  JSON.parse(sbom);

  const request = http.request(
    {
      hostname: endpoint.hostname,
      port: endpoint.port,
      path: endpoint.pathname,
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Content-Length": Buffer.byteLength(sbom),
        "X-Api-Key": "mock-api-key"
      }
    },
    (response) => {
      let responseBody = "";
      response.setEncoding("utf8");
      response.on("data", (chunk) => {
        responseBody += chunk;
      });
      response.on("end", () => {
        const log = [
          `timestamp=${new Date().toISOString()}`,
          `endpoint=${endpoint.href}`,
          `status=${response.statusCode}`,
          `response=${responseBody}`
        ].join("\n") + "\n";

        fs.mkdirSync(path.dirname(outputPath), { recursive: true });
        fs.writeFileSync(outputPath, log);
        console.log(log);
      });
    }
  );

  request.on("error", (error) => {
    console.error(`Falha na submissão: ${error.message}`);
    process.exit(1);
  });

  request.write(sbom);
  request.end();
} catch (error) {
  console.error(`Falha ao ler o SBOM: ${error.message}`);
  process.exit(2);
}
