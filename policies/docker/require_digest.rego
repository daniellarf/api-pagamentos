package main
import future.keywords.if
import future.keywords.contains

deny[msg] if {
  input[i].Cmd == "from"
  image := input[i].Value[0]
  not has_digest(image)
  msg := sprintf("Linha %d: imagem base '%v' não possui digest.", [i, image])
}

has_digest(image) if {
  contains(image, "@sha256:")
}
