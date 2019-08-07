output "loadbalancer_ip_address" {
  value = "${kubernetes_ingress.metabase_ingress.load_balancer_ingress.0.ip}"
}

output "metabase_hostname" {
  value = "${kubernetes_ingress.metabase_ingress.spec.0.rule.0.host}"
}
