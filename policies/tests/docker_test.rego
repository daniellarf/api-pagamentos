package main
test_usuario_root_reprovado {
  results := deny with input as [
    {"Cmd": "from", "Value": ["node:20-alpine@sha256:abc"]},
    {"Cmd": "user", "Value": ["root"]},
  ]
  some m
  results[m]
  contains(m, "USER root não é permitido")
}
test_imagem_sem_digest_reprovada {
  results := deny with input as [
    {"Cmd": "from", "Value": ["node:20-alpine"]},
    {"Cmd": "user", "Value": ["node"]},
  ]
  some m
  results[m]
  contains(m, "deve usar digest")
}
test_dockerfile_conforme_aprovado {
  results := deny with input as [
    {"Cmd": "from", "Value": ["node:20-alpine@sha256:abc"]},
    {"Cmd": "user", "Value": ["node"]},
  ]
  count(results) == 0