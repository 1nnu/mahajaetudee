resource "hcloud_network" "privateNetwork" {
  name     = "my-net"
  ip_range = "192.168.0.0/24"
}

resource "hcloud_network_subnet" "subnet-a" {
  network_id   = hcloud_network.privateNetwork.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = "192.168.0.0/28"
}