resource "hcloud_ssh_key" "key" {
  name       = "SSH Key"
  public_key = var.SSH_PUB_KEY
}

resource "hcloud_network" "network" {
  name     = "internal"
  ip_range = "10.0.0.0/16"
}

resource "hcloud_network_subnet" "subnet" {
  network_id   = hcloud_network.network.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = "10.0.0.0/24"
}

resource "hcloud_network_route" "route" {
  network_id  = hcloud_network.network.id
  destination = "0.0.0.0/0"
  gateway     = "10.0.0.2"
}

resource "hcloud_server" "gateway" {
  name        = "gateway"
  image       = "debian-11"
  server_type = "cx11"
  ssh_keys = [ hcloud_ssh_key.key.id ]

  user_data = templatefile("../data/gateway.yml", {
    network_prefix = "10.0.0.0/24"
  })

  network {
    network_id = hcloud_network.network.id
    ip         = "10.0.0.2"
  }

  depends_on = [
    hcloud_network_subnet.subnet
  ]

  firewall_ids = [ hcloud_firewall.gateway.id ]
}

resource "hcloud_server" "instance" {
  count       = 1
  name        = "instance-${count.index}"
  image       = "debian-11"
  server_type = "cx11"
  ssh_keys = [ hcloud_ssh_key.key.id ]

  user_data = templatefile("../data/instance.yml", {})

  network {
    network_id = hcloud_network.network.id
  }

  depends_on = [
    hcloud_network_subnet.subnet,
    hcloud_server.gateway
  ]

  firewall_ids = [ hcloud_firewall.internal.id ]
}

resource "hcloud_firewall" "gateway" {
  name = "gateway"
  rule {
    direction = "in"
    protocol = "tcp"
    port = "22"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "out"
    protocol = "tcp"
    port = "443"
    destination_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
}

resource "hcloud_firewall" "internal" {
  name = "internal"
  rule {
    direction = "out"
    protocol  = "icmp"
    destination_ips = [ 
      "0.0.0.0/0",
      "::/0"
    ]
  }
  # rule {
  #   direction = "out"
  #   protocol  = "icmp"
  #   destination_ips = []
  # }
  # rule {
  #   direction = "out"
  #   protocol  = "udp"
  #   port = "any"
  #   destination_ips = []
  # }
  # rule {
  #   direction = "out"
  #   protocol  = "gre"
  #   destination_ips = []
  # }
  # rule {
  #   direction = "out"
  #   protocol  = "esp"
  #   destination_ips = []
  # }
}