provider "google" {
  credentials = file("~/Proyectos/Web_Cecilia/sre-gcp-394115-7090f165d4fd.json")
  project = var.project_id
  region  = var.region
  zone    = var.zone
}


# # DNS Record
# resource "google_dns_record_set" "www" {
#   name         = "www.your-domain.com."
#   type         = "A"
#   ttl          = 300
#   managed_zone = "your-zone-name"
#   rrdatas      = [google_compute_forwarding_rule.default.IP_address]
# }


# webserver
resource "google_compute_instance" "web_cecilia" {
  name              = "ux-itechile-cl"
  machine_type      = "e2-micro"
  zone              = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = 10
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

  service_account {
    scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/pubsub",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append",
    ]
  }


  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y git curl apt-transport-https ca-certificates software-properties-common",
      "curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -",
      "sudo add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable\"",
      "sudo apt update",
      "sudo apt install -y docker-ce",
      "sudo curl -L \"https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose",
      "sudo chmod +x /usr/local/bin/docker-compose",
    ]
  }

  connection {
    type        = "ssh"
    user        = "debian"
#    private_key = file("~/.ssh/google_compute_engine")
    host        = google_compute_instance.web_cecilia.network_interface[0].access_config[0].nat_ip
  }
}
