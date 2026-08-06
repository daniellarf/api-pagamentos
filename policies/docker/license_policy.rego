package docker

deny[msg] {
  some i
  input[i].Cmd == "LABEL"
  not input[i].Value["license"]
  msg := sprintf("Linha %d: imagem sem licença definida.", [i])
}
