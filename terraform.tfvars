# Application Definition 
app_name        = "yuvicloud" #do NOT enter any spaces
app_environment = "dev" # Dev, Test, Prod, etc
app_domain      = "yuvicloud.com"
app_project     = "calcium-field-306715"

# GCP Settings
gcp_region_1  = "us-east1"
gcp_zone_1    = "us-east1-b"
### if you want to build server from your laptop inout your key and enale it.
## if you use github actions."No need to enable"
#gcp_auth_file = "<ENTER YOUR SERVICE ACCOUNT JSON KEY> "   

# GCP Netwok
public_subnet_cidr_1  = "10.142.1.0/24"
#node_count            = "2"
ssh_username = "root"
#ssh_pub_key_path = "../GCP/id_rsa.pub"
vm_type = "f1-micro"
os_type = "ubuntu-os-cloud/ubuntu-1804-lts"
