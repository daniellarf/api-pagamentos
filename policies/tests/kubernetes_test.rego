package main
test_container_sem_limite_memoria_reprovado {
  results := deny with input as {
    "kind": "Deployment",
    "spec": {"template": {"spec": {"containers": [
      {"name": "api", "securityContext": {"runAsNonRoot": true}},
    ]}}},
  }
  some m
  results[m]
  contains(m, "sem limite de memória")
}
test_container_root_reprovado {
  results := deny with input as {
    "kind": "Deployment",
    "spec": {"template": {"spec": {"containers": [
      {"name": "api", "resources": {"limits": {"memory": "256Mi"}}},
    ]}}},
  }
  some m
  results[m]
  contains(m, "runAsNonRoot")
}
test_deployment_conforme_aprovado {
  results := deny with input as {
    "kind": "Deployment",
    "spec": {"template": {"spec": {"containers": [
      {
        "name": "api",
        "securityContext": {"runAsNonRoot": true},
        "resources": {"limits": {"memory": "256Mi"}},
      },
    ]}}},
  }
  count(results) == 0
}