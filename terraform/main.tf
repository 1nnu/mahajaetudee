resource "hcloud_primary_ip" "application_ip" {
  name          = "instance1"
  datacenter    = local.instances_settings.datacenter
  type          = "ipv4"
  assignee_type = "server"
  auto_delete   = false
}

resource "hcloud_ssh_key" "main" {
  name       = "main-ssh-key"
  public_key = file("./public.pub")
}


resource "hcloud_server" "application_node" {
  name        = "application-node"
  image       = local.instances_settings.os_type
  server_type = local.instances_settings.server_type
  location    = local.instances_settings.location
  ssh_keys    = [hcloud_ssh_key.main.id]
  firewall_ids = [hcloud_firewall.firewall.id]
  labels       = {
    "node_type" : "application"
  }

  network {
    network_id = hcloud_network.privateNetwork.id
    ip         = "192.168.0.4"
  }

  public_net {
    ipv4_enabled = true
    ipv4 = hcloud_primary_ip.application_ip.id
    ipv6_enabled = false
  }

  depends_on = [
    hcloud_network_subnet.subnet-a
  ]

  user_data = <<EOD
#cloud-config
network:
  version: 2
  ethernets:
    enp7s0:
      dhcp4: false
      addresses:
        - 192.168.0.4/28
      nameservers:
        addresses: [8.8.8.8]
runcmd:
  - echo 1 > /proc/sys/net/ipv4/ip_forward
  - iptables -t nat -A POSTROUTING -s 192.168.0.0/28 -o eth0 -j MASQUERADE
  - iptables -A FORWARD -i eth0 -o enp7s0 -m state --state RELATED,ESTABLISHED -j ACCEPT
  - iptables -A FORWARD -i enp7s0 -o eth0 -j ACCEPT
EOD

}

resource "hcloud_server" "db_node" {
  name        = "database-node"
  image       = local.instances_settings.os_type
  server_type = local.instances_settings.server_type
  location    = local.instances_settings.location
  ssh_keys    = [hcloud_ssh_key.main.id]
  firewall_ids = [hcloud_firewall.firewall.id]
  labels  	  = {
    "node_type" : "db"
  }

  network {
    network_id = hcloud_network.privateNetwork.id
    ip         = "192.168.0.5"
  }

  public_net {
    ipv4_enabled = false
    ipv6_enabled = false
  }

  depends_on = [
    hcloud_network_subnet.subnet-a
  ]

  user_data = <<EOD
#cloud-config
network:
  version: 2
  ethernets:
    enp7s0:
      dhcp4: false
      addresses:
        - 192.168.0.5/28
      nameservers:
        addresses: [8.8.8.8]
      routes:
        - to: default
          via: 192.168.0.4
EOD
}

output "bastion_ip" {
  description = "Public IP of the application host"
  value       = hcloud_server.application_node.ipv4_address
}
