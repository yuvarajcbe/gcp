# setup the GCP provider | provider.tf

terraform {
  required_version = ">= 0.12"
}

provider "google" {
  project = var.app_project
  #credentials = file(var.gcp_auth_file)
  region  = var.gcp_region_1
  zone    = var.gcp_zone_1
}

terraform {
  backend "gcs" {
    bucket      = "yuva-global-gsb"
    prefix      = "network-tfsate"
   #credentials = ".././GCP/calcium-field-306715-5333e7bec98a.json"
  }
}

#Single region, public only network configuration | network.tf

# create VPC
resource "google_compute_network" "vpc" {
  name                    = "${var.app_name}-${var.app_environment}-vpc"
  auto_create_subnetworks = "false"
  routing_mode            = "GLOBAL"
}
#
# create public subnet
resource "google_compute_subnetwork" "public_subnet_1" {
  name          = "${var.app_name}-${var.app_environment}-public-subnet-1"
  ip_cidr_range = var.public_subnet_cidr_1
  network       = google_compute_network.vpc.name
  region        = var.gcp_region_1
}

# allow internal icmp (disable for better security)
resource "google_compute_firewall" "allow-internal" {
  name    = "${var.app_name}-${var.app_environment}-fw-allow-internal"
  network = google_compute_network.vpc.name
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  source_ranges = [
    var.public_subnet_cidr_1
  ]
}

# Basic Network Firewall Rules | network-firewall.tf  

# Allow http
resource "google_compute_firewall" "allow-http" {
  name    = "${var.app_name}-${var.app_environment}-fw-allow-http"
  network = google_compute_network.vpc.name
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  target_tags = ["http"] 
}

# allow https
resource "google_compute_firewall" "allow-https" {
  name    = "${var.app_name}-${var.app_environment}-fw-allow-https"
  network = google_compute_network.vpc.name
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
  target_tags = ["https"] 
}

# allow ssh
resource "google_compute_firewall" "allow-ssh" {
  name    = "${var.app_name}-${var.app_environment}-fw-allow-ssh"
  network = google_compute_network.vpc.name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  target_tags = ["ssh"]
}

# allow rdp
#resource "google_compute_firewall" "allow-rdp" {
#  name    = "${var.app_name}-${var.app_environment}-fw-allow-rdp"
#  network = "${google_compute_network.vpc.name}"
#  allow {
#    protocol = "tcp"
#    ports    = ["3389"]
#  }
#  target_tags = ["rdp"]
#}

# Create Google Cloud VM | vm.tf

# Terraform plugin for creating random ids
#resource "random_id" "instance_id" {
# byte_length = 4
#}

# Create VM #1
resource "google_compute_instance" "vm_instance_public" {
  count = 2  
  name         = "${var.app_name}-${var.app_environment}-vm-${count.index}"
  machine_type = var.vm_type
  zone         = var.gcp_zone_1
  hostname     = "${var.app_name}-vm-${var.app_domain}"
  tags         = ["ssh","http"]

  boot_disk {
    initialize_params {
      image = var.os_type
    }
  }
   
  metadata = {
      ssh-keys = "${var.ssh_username}:${file(var.ssh_pub_key_path)}"
  } 

    metadata_startup_script = "apt-get update; apt-get install -yq default-jdk docker* maven; systemctl start docker"
#
  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.default.email
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}
 network_interface {
    #network       = google_compute_network.vpc.name
    subnetwork    = google_compute_subnetwork.public_subnet_1.name
    access_config { }
  }
} 
