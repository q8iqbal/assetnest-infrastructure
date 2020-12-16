variable "do_token" { }

provider "digitalocean" {
    token = var.do_token
}

data "digitalocean_ssh_key" "windows" {
    name = "windows laptop"
}

data "digitalocean_ssh_key" "linux" {
    name = "linux laptop"
}

variable "region" {
    type = string
    default = "sgp1"
}

variable "droplet_count" {
    type = number
    default = 1
}

variable "droplet_size" {
    type = string
    default = "s-1vcpu-1gb"
}

resource "digitalocean_droplet" "assetnest" {
    count = var.droplet_count
    image  = "docker-20-04"
    name   = "assetnest-${var.region}-${count.index + 1}"
    region = var.region
    size   = var.droplet_size
    ssh_keys = [
        data.digitalocean_ssh_key.windows.id,
        data.digitalocean_ssh_key.linux.id,
    ]
}

resource "null_resource" "temp" {
    count = var.droplet_count

    provisioner "file"{
        source = "../docker/assetnest"
        destination = "/home"
        connection {
            type = "ssh"
            user = "root"
            host = digitalocean_droplet.assetnest[count.index].ipv4_address
        }
    }

    provisioner "local-exec" {
        command = "echo '${digitalocean_droplet.assetnest[count.index].name} ansible_host=${digitalocean_droplet.assetnest[count.index].ipv4_address} ansible_ssh_user=root ansible_python_interpreter=/usr/bin/python3' >> ../ansible/hosts"
    }
}

//nambah dns record

resource "digitalocean_domain" "default" {
    name = "assetnest.me"
}

# Add an A record to the domain for www.example.com.
resource "digitalocean_record" "entah" {
    count = var.droplet_count
    domain = digitalocean_domain.default.name
    type   = "A"
    name   = "@"
    value  = digitalocean_droplet.assetnest[count.index].ipv4_address
}

resource "digitalocean_record" "api" {
    count = var.droplet_count
    domain = digitalocean_domain.default.name
    type   = "A"
    name   = "api"
    value  = digitalocean_droplet.assetnest[count.index].ipv4_address
}

output "server_ip" {
    value = digitalocean_droplet.assetnest.*.ipv4_address
}