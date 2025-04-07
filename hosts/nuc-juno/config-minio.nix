_: {
  # # Minio service configuration - customized for this host
  services.minio = {
    # Server configuration
    listenAddress = "10.32.40.43:9000";
    consoleAddress = "10.32.40.43:9001";

    # Data directory and distributed server configuration
    dataDir = [
      "http://10.32.40.41:9000/minio/data"
      "http://10.32.40.43:9000/minio/data"
    ];
  };
  # Configure as primary Keepalived node
  services.keepalived.vrrpInstances."minio-vip".priority = 200;
}
