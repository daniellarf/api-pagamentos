package main
deny[msg] {
  input[i].Cmd == "from"
  image := input[i].Value[0]
  not contains(image, "@sha256:")
  msg := sprintf("Linha %d: imagem base '%v' deve usar digest @sha256.", [i, image])
}