const fs = require("fs");

const sbomPath = process.argv[2] || "sbom/sbom-cyclonedx.json";
const allowlistPath =
  process.argv[3] || "policies/sbom/allowed-licenses.txt";

function licenseValue(entry) {
  if (!entry) return null;
  if (typeof entry === "string") return entry.trim();
  if (entry.expression) return entry.expression.trim();
  if (entry.license?.id) return entry.license.id.trim();
  if (entry.license?.name) return entry.license.name.trim();
  return null;
}

try {
  const sbom = JSON.parse(fs.readFileSync(sbomPath, "utf8"));
  const allowed = new Set(
    fs.readFileSync(allowlistPath, "utf8")
      .split(/\r?\n/)
      .map((line) => line.trim())
      .filter(Boolean)
  );

  const rejected = [];
  const unknown = [];
  let checked = 0;

  for (const component of sbom.components || []) {
    const values = (component.licenses || [])
      .map(licenseValue)
      .filter(Boolean);

    if (values.length === 0) {
      unknown.push(`${component.name}@${component.version || "unknown"}`);
      continue;
    }

    checked += 1;

    const accepted = values.some((value) =>
      value.split(/\s+(?:OR|AND)\s+/i).some((part) => allowed.has(part.trim()))
    );

    if (!accepted) {
      rejected.push(
        `${component.name}@${component.version || "unknown"}: ${values.join(", ")}`
      );
    }
  }

  console.log(`Componentes no SBOM: ${(sbom.components || []).length}`);
  console.log(`Componentes com licença analisada: ${checked}`);
  console.log(`Componentes sem licença identificada: ${unknown.length}`);
  console.log(`Componentes fora da allowlist: ${rejected.length}`);

  if (unknown.length) {
    console.log("\nSem licença identificada:");
    unknown.forEach((item) => console.log(`- ${item}`));
  }

  if (rejected.length) {
    console.error("\nFora da allowlist:");
    rejected.forEach((item) => console.error(`- ${item}`));
    process.exit(1);
  }

  console.log("\nPolítica de licenças aprovada.");
} catch (error) {
  console.error(`Falha ao analisar licenças: ${error.message}`);
  process.exit(2);
}
