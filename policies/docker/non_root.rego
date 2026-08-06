package docker

deny[msg] {
  some i
  input[i].Cmd == "USER"
  input[i].Value == "root"
  msg := "Container não deve rodar como root"
}
