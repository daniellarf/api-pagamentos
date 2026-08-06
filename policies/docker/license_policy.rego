package main
denied_licenses := {"GPL-3.0-only", "AGPL-3.0-only", "SSPL-1.0"}
deny[msg] {
  component := input.components[_]
  license := component.licenses[_].license.id
  denied_licenses[license]
  msg := sprintf("Componente '%v' usa licença proibida: %v.", [component.name, license])
}