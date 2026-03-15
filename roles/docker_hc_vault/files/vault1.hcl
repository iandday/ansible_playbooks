ui = true
api_addr = "https://hcv_1:8200"
cluster_addr = "https://hcv_1:8201"
disable_mlock = true
log_level = "info"
storage "raft" {
  path = "/vault/data"
  node_id = "hcv_1"
}

listener "tcp" {
  address = "0.0.0.0:8200"
  cluster_address = "0.0.0.0:8201"
  tls_cert_file = "/vault/config/hcv.crt"
  tls_key_file  = "/vault/config/hcv.key"
  tls_client_ca_file = "/vault/config/root-ca.crt"
  tls_disable        = 0
  tls_min_version    = "tls12"
}