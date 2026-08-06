# API Pagamentos — Compliance contínuo

Projeto acadêmico de DevSecOps para aplicar controles de segurança e rastreabilidade em uma API Node.js.

## Estado atual

Implementado e validado localmente:

- aplicação Node.js executando na porta `3000`;
- imagem Docker construída e executada com sucesso;
- cinco policies Rego para Dockerfile;
- policy Rego para manifesto Kubernetes;
- seis testes Rego aprovados com `conftest verify`;
- Dockerfile principal e `Dockerfile.good` aprovados pelo Conftest;
- `Dockerfile.bad` bloqueado intencionalmente;
- SBOMs gerados em CycloneDX JSON e SPDX JSON;
- pipeline de CI preparada para validar policies e gerar os dois SBOMs.

Preparado, mas dependente de ambiente externo para comprovação final:

- assinatura keyless com Cosign via OIDC;
- SLSA Provenance;
- verificação de assinatura no admission controller;
- execução completa no GitHub Actions.

Durante a validação, o GitHub Actions apresentou indisponibilidade de runner hospedado. Os controles de Policy as Code, Docker e SBOM foram validados localmente.

## Estrutura principal

```text
.github/workflows/     pipelines de CI e release
k8s/                   manifesto da aplicação e policies de admission
policies/docker/       policies Rego para Dockerfile
policies/kubernetes/   policies Rego para Kubernetes
policies/sbom/         allowlist de licenças
policies/tests/        testes Rego
sbom/                  SBOM CycloneDX e SPDX
scripts/               scripts de auditoria e integrações auxiliares
evidence/              saídas de exemplo e evidências locais
dashboard/             dashboard HTML com KPIs
```

## Execução local

Instalar dependências e iniciar a API:

```bash
npm install
npm start
```

A API deve responder em:

```text
http://localhost:3000
```

## Docker

Construir a imagem:

```bash
docker build -t api-pagamentos:local .
```

Executar:

```bash
docker run --rm -p 3000:3000 api-pagamentos:local
```

Testar:

```bash
curl http://localhost:3000
```

## Policy as Code

Executar os testes Rego:

```bash
conftest verify --policy policies
```

Validar o Dockerfile principal:

```bash
conftest test Dockerfile \
  --policy policies/docker \
  --namespace docker
```

Validar o manifesto Kubernetes:

```bash
conftest test k8s/deployment.yaml \
  --policy policies/kubernetes \
  --namespace kubernetes
```

Validar que o exemplo inseguro é bloqueado:

```bash
conftest test Dockerfile.bad \
  --policy policies/docker \
  --namespace docker
```

## SBOM

Gerar CycloneDX:

```bash
syft dir:. -o cyclonedx-json > sbom/sbom-cyclonedx.json
```

Gerar SPDX:

```bash
syft dir:. -o spdx-json > sbom/sbom-spdx.json
```

Validar o CycloneDX:

```bash
docker run --rm \
  -v "$(pwd -W):/data" \
  cyclonedx/cyclonedx-cli:latest \
  validate --input-file /data/sbom/sbom-cyclonedx.json
```

Executar a análise exigida:

```bash
docker run --rm \
  -v "$(pwd -W):/data" \
  cyclonedx/cyclonedx-cli:latest \
  analyze \
  --input-file /data/sbom/sbom-cyclonedx.json \
  --output-format text
```

## Política de licenças

A allowlist fica em:

```text
policies/sbom/allowed-licenses.txt
```

Executar:

```bash
node scripts/check-licenses.js \
  sbom/sbom-cyclonedx.json \
  policies/sbom/allowed-licenses.txt
```

O script reprova licenças fora da allowlist. Componentes sem licença identificada são reportados separadamente para análise.

## Dependency-Track mockado

Terminal 1:

```bash
node scripts/mock-dependency-track-server.js
```

Terminal 2:

```bash
node scripts/submit-sbom.js \
  sbom/sbom-cyclonedx.json \
  evidence/dependency-track-api.log
```

O segundo comando faz uma submissão HTTP real para o servidor local mockado e grava o log da resposta.

## Relatório mensal e dashboard

Gerar relatório:

```bash
node scripts/monthly-report.js
```

Gerar dashboard HTML com quatro KPIs:

```bash
node scripts/generate-dashboard.js
```

Abrir:

```text
dashboard/index.html
```

## Admission e cadeia de suprimentos

O manifesto `k8s/admission/clusterimagepolicy.yaml` prepara um controle de admissão baseado no Sigstore Policy Controller. A comprovação de bloqueio exige um cluster com o controller instalado e uma imagem assinada.

O workflow de release prepara:

- build e push da imagem;
- assinatura keyless com Cosign usando OIDC;
- anexação do SBOM;
- atestação de vulnerabilidades;
- geração de SLSA Provenance.

A evidência final de `cosign verify`, `cosign verify-attestation` e bloqueio no cluster depende da execução em GitHub Actions e de um cluster Kubernetes.

## Mapeamento de controles

| Controle implementado | Referência |
|---|---|
| Usuário não-root e imagem fixa por digest | CIS Docker Benchmark |
| Limites de recursos e `runAsNonRoot` | Kubernetes Pod Security Standards |
| SBOM CycloneDX/SPDX | NIST SSDF PS.3 e OWASP SCVS |
| Assinatura e proveniência | SLSA e NIST SSDF PS.2 |
| Policy as Code no CI | NIST SSDF PO.3 e PW.7 |
| Allowlist de licenças | Governança de componentes de terceiros |
| Relatório e KPIs | NIST SSDF PO.4 e melhoria contínua |

## Limitações conhecidas

- A execução completa do GitHub Actions depende da disponibilidade de runners hospedados.
- A verificação de assinatura no admission controller exige um cluster configurado.
- O Dependency-Track foi implementado em modo mockado, conforme permitido pelo requisito.
