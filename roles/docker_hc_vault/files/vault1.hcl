ui = true
api_addr = "https://hcv_1:8200"
cluster_addr = "https://hcv_1:8201"
disable_mlock = false
log_level = "debug"
storage "raft" {
  path = "/vault/file"
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