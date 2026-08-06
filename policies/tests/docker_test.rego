package main

test_usuario_root_reprovado if {
  results := data.docker.deny with input as [
    {"Cmd": "from", "Value": ["node:20-alpine@sha256:abc"]},
    {"Cmd": "user", "Value": ["root"]},
  ]

  some m in results
  contains(m, "USER root não é permitido")
}

test_imagem_sem_digest_reprovada if {
  results := data.docker.deny with input as [
    {"Cmd": "from", "Value": ["node:20-alpine"]},
    {"Cmd": "user", "Value": ["node"]},
  ]

  some m in results
  contains(m, "deve usar digest")
}

test_dockerfile_conforme_aprovado if {
  results := data.docker.deny with input as [
    {"Cmd": "from", "Value": ["node:20-alpine@sha256:abc"]},
    {"Cmd": "user", "Value": ["node"]},
    {
      "Cmd": "label",
      "Value": ["org.opencontainers.image.licenses=MIT"]
    },
    {
      "Cmd": "healthcheck",
      "Value": ["CMD", "node", "--version"]
    },
  ]

  count(results) == 0
}