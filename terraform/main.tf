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

  depends_on = [
    hcloud_network_subnet.subnet-a
  ]
}