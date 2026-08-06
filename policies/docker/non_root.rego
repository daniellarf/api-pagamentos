package main
deny[msg] {
  input.kind == "Deployment"
  c := input.spec.template.spec.containers[_]
  not c.securityContext.runAsNonRoot
  msg := sprintf("Container '%v' deve usar runAsNonRoot: true.", [c.name])
}