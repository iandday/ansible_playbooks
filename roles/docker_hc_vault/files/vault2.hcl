ui = true
api_addr = "https://hcv_2:8200"
cluster_addr = "https://hcv_2:8201"
disable_mlock = false
log_level = "debug"
storage "raft" {
  path = "/vault/file"
  node_id = "hcv_2"

  retry_join {
    leader_api_addr = "https://hcv_1:8200"
    leader_ca_cert_file = "/vault/config/root-ca.crt"
  }
  retry_join {
    leader_api_addr = "https://hcv_3:8200"
    leader_ca_cert_file = "/vault/config/root-ca.crt"
  }
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