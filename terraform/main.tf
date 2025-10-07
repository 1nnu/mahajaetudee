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
    ip         = "192.168.0.1"
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
write_files:
  - path: /etc/networkd-dispatcher/routable.d/10-eth0-post-up
    content: |
      #!/bin/bash
      
      echo 1 > /proc/sys/net/ipv4/ip_forward
      iptables -t nat -A POSTROUTING -s '192.168.0.0/24' -o eth0 -j MASQUERADE
    permissions: '0755'

runcmd:
  - reboot
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
    ip         = "192.168.0.2"
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
write_files:
  - path: /etc/systemd/network/10-enp7s0.network
    content: |
      # Custom network configuration added by cloud-init
      [Match]
      Name=enp7s0

      [Network]
      DHCP=yes
      Gateway=192.168.0.1
    append: true

  - path: /etc/systemd/resolved.conf
    content: |
      [Resolve]
      DNS=185.12.64.2 185.12.64.1
      FallbackDNS=8.8.8.8
    append: true

runcmd:
  - reboot
EOD
}

output "bastion_ip" {
  description = "Public IP of the application host"
  value       = hcloud_server.application_node.ipv4_address
}
  