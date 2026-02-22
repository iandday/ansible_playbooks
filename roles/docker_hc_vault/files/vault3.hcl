ui = true
api_addr = "https://hcv_3:8200"
cluster_addr = "https://hcv_3:8201"
disable_mlock = false
log_level = "debug"
storage "raft" {
  path = "/vault/file"
  node_id = "hcv_3"

  retry_join {
    leader_api_addr = "https://hcv_1:8200"
    leader_ca_cert_file = "/vault/config/root-ca.crt"
      leader_tls_servicename = "hcv_1"
  }
  retry_join {
    leader_api_addr = "https://hcv_2:8200"
    leader_ca_cert_file = "/vault/config/root-ca.crt"
    leader_tls_servicename = "hcv_2"
  }
}

listener "tcp" {
  address = "0.0.0.0:8200"
  tls_cert_file = "/vault/config/cert.crt"
  tls_key_file  = "/vault/config/cert.key"
}