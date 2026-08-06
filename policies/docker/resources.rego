package docker

deny[msg] {
  some i
  input[i].Cmd == "RESOURCE"
  not input[i].Value["limits"]["cpu"]
  msg := sprintf("Linha %d: container sem limite de CPU definido.", [i])
}

deny[msg] {
  some i
  input[i].Cmd == "RESOURCE"
  not input[i].Value["limits"]["memory"]
  msg := sprintf("Linha %d: container sem limite de memória definido.", [i])
}
