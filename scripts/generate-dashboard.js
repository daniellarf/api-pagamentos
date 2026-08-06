const fs = require("fs");
const path = require("path");

const dashboardDir = path.resolve("dashboard");
fs.mkdirSync(dashboardDir, { recursive: true });

let report = {};
try {
  const files = fs.readdirSync("reports")
    .filter((name) => name.startsWith("monthly-report-") && name.endsWith(".json"))
    .sort();

  if (files.length) {
    report = JSON.parse(
      fs.readFileSync(path.join("reports", files[files.length - 1]), "utf8")
    );
  }
} catch {
  report = {};
}

const kpis = [
  ["Testes Rego aprovados", report.regoTestsPassed ?? 0],
  ["Componentes no SBOM", report.sbomComponents ?? 0],
  ["Componentes com licença", report.componentsWithLicense ?? 0],
  ["Evidência Dependency-Track", report.dependencyTrackEvidence ? "Sim" : "Não"]
];

const cards = kpis.map(([label, value]) => `
  <article class="card">
    <div class="value">${value}</div>
    <div class="label">${label}</div>
  </article>`).join("");

const html = `<!doctype html>
<html lang="pt-BR">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Dashboard de Compliance</title>
<style>
body{font-family:Arial,sans-serif;margin:0;background:#f5f7fa;color:#1f2937}
main{max-width:1000px;margin:40px auto;padding:20px}
h1{margin-bottom:8px}
.subtitle{color:#6b7280;margin-bottom:24px}
.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(210px,1fr));gap:18px}
.card{background:#fff;border:1px solid #e5e7eb;border-radius:12px;padding:24px;box-shadow:0 2px 8px rgba(0,0,0,.05)}
.value{font-size:34px;font-weight:700;margin-bottom:8px}
.label{color:#4b5563}
footer{margin-top:24px;color:#6b7280;font-size:14px}
</style>
</head>
<body>
<main>
<h1>Dashboard de Compliance</h1>
<div class="subtitle">API Pagamentos — indicadores gerados a partir das evidências locais.</div>
<section class="grid">${cards}</section>
<footer>Gerado em ${new Date().toLocaleString("pt-BR")}</footer>
</main>
</body>
</html>`;

fs.writeFileSync(path.join(dashboardDir, "index.html"), html);
console.log(`Dashboard gerado em ${path.join(dashboardDir, "index.html")}`);
