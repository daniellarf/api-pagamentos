package main

approved := {
  "node:20-alpine@sha256:",
  "cgr.dev/chainguard/",
  "gcr.io/distroless/"
}

deny[msg] {
  some i
  input[i].Cmd == "from"
  image := input[i].Value[0]
  not allowed_image(image)
  msg := sprintf("Linha %d: imagem base '%v' não está aprovada.", [i, image])
}

allowed_image(image) {
  startswith(image, approved[_])
}
