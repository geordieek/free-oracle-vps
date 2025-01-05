# New compartment to logically group resources
resource "oci_identity_compartment" "vps" {
  description = "VPS Compartment"
  name        = "vps"
}

# Fetch the availability domains for the specified compartment
data "oci_identity_availability_domains" "test" {
  compartment_id = oci_identity_compartment.vps.id
}

# Virtual Cloud Network (VCN) for private networking
resource "oci_core_vcn" "vps" {
  compartment_id = oci_identity_compartment.vps.id
  cidr_blocks    = [var.cidr] # Define the network range (e.g., 10.0.0.0/16)
  display_name   = "vps"
  dns_label      = "vps" # Short DNS label for internal resolution
}

# Internet Gateway to allow outbound internet access from the VCN
resource "oci_core_internet_gateway" "vps" {
  compartment_id = oci_identity_compartment.vps.id
  vcn_id         = oci_core_vcn.vps.id
  route_table_id = oci_core_vcn.vps.default_route_table_id # Use default route table
  enabled        = true
  display_name   = "vps"
}

# Define a route table to direct internet traffic through the Internet Gateway
resource "oci_core_route_table" "vps" {
  compartment_id = oci_identity_compartment.vps.id
  vcn_id         = oci_core_vcn.vps.id
  display_name   = "vps"

  # Add a route rule for internet traffic
  route_rules {
    network_entity_id = oci_core_internet_gateway.vps.id # Internet Gateway ID
    destination_type  = "CIDR_BLOCK"
    destination       = "0.0.0.0/0" # Default route for all outbound traffic
  }
}

# Define security rules for the VCN (firewall-like functionality)
resource "oci_core_security_list" "vps" {
  compartment_id = oci_identity_compartment.vps.id
  vcn_id         = oci_core_vcn.vps.id

  # Allow incoming SSH traffic (port 22)
  ingress_security_rules {
    protocol    = 6           # TCP
    source      = "0.0.0.0/0" # Any IP address
    source_type = "CIDR_BLOCK"
    stateless   = false
    tcp_options {
      min = 22
      max = 22
    }
  }

  # Allow ICMP traffic for diagnostics (e.g., ping)
  ingress_security_rules {
    protocol    = 1 # ICMP
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = false
    icmp_options {
      type = 3 # Type 3: Destination Unreachable
      code = 4 # Code 4: Fragmentation Needed
    }
  }

  # Allow ICMP traffic from within the CIDR block
  ingress_security_rules {
    protocol    = 1        # ICMP
    source      = var.cidr # VCN CIDR range
    source_type = "CIDR_BLOCK"
    stateless   = false
    icmp_options {
      type = 3
    }
  }

  # Dynamically open additional ports specified in the "opened_ports" variable
  dynamic "ingress_security_rules" {
    for_each = var.opened_ports
    iterator = port
    content {
      protocol    = 6 # TCP
      source      = "0.0.0.0/0"
      source_type = "CIDR_BLOCK"
      stateless   = true
      tcp_options {
        min = port.value
        max = port.value
      }
    }
  }

  # Allow all outgoing traffic
  egress_security_rules {
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }
}

# Subnet within the VCN
resource "oci_core_subnet" "vps" {
  compartment_id    = oci_identity_compartment.vps.id
  vcn_id            = oci_core_vcn.vps.id
  cidr_block        = var.cidr # Subnet range (same as VCN in this example)
  dns_label         = "vps"
  route_table_id    = oci_core_route_table.vps.id     # Use the custom route table
  security_list_ids = [oci_core_security_list.vps.id] # Apply the security list
}

# Use adarobin's module to create an A1 Always Free compute instance
# see: https://registry.terraform.io/modules/adarobin/A1-Always-Free-Instance/oci/latest
module "A1-Always-Free-Instance" {
  source  = "adarobin/A1-Always-Free-Instance/oci"
  version = "0.3.0"

  # Link to resources created earlier
  compartment_id      = oci_identity_compartment.vps.id
  availability_domain = data.oci_identity_availability_domains.test.availability_domains[0].name
  subnet_id           = oci_core_subnet.vps.id

  # Instance specifications
  ocpus                    = var.cpus                # Number of CPUs
  boot_volume_size_in_gbs  = var.disk_size           # Boot disk size
  hostname                 = var.hostname            # Hostname for the instance
  assign_public_ip         = var.assign_public_ip    # Enable public IP assignment
  memory_in_gbs            = var.memory              # Memory in GBs
  operating_system         = var.os                  # OS (e.g., Canonical Ubuntu)
  operating_system_version = var.os_version          # OS version (e.g., 22.04 Minimal aarch64)
  ssh_authorized_keys      = var.ssh_authorized_keys # SSH public key(s) for login
}

# Budget to try and keep things free
resource "oci_budget_budget" "free_budget" {
  compartment_id = var.tenancy_ocid
  target_type    = "COMPARTMENT"

  # Provide the target compartment OCID (this applies the budget to the entire account)
  targets = [var.tenancy_ocid]

  # Other required attributes
  amount                 = 1
  description            = "Monthly budget for the entire account"
  reset_period           = "MONTHLY"
  processing_period_type = "MONTH"

  # Optional attributes
  display_name = "Free"
}

# Budget alert to email me once 0.01 is spent
resource "oci_budget_alert_rule" "any_spend_alert_rule" {
  budget_id      = oci_budget_budget.free_budget.id
  threshold      = 0.01
  threshold_type = "ABSOLUTE"
  type           = "ACTUAL"

  # Optional fields
  description  = "Alert when any spend is made"
  display_name = "Free"
  recipients   = var.personal_email
}

# Topic to pub to when high budget is hit
resource "oci_ons_notification_topic" "budget_alert_topic" {
  compartment_id = oci_identity_compartment.vps.id
  name           = "high_budget_alert"
  description    = "Topic to notify when budget limit is reached"
}

# Subscription that hits an endpoint when high budget alert is hit, which will kill all resources
resource "oci_ons_subscription" "budget_alert_subscription" {
  compartment_id = oci_identity_compartment.vps.id
  # TODO: Actually create an app that kills all services, and update endpoint
  endpoint = "https://TODO-my-vm-ip:8080/alert" # The HTTP endpoint
  protocol = "CUSTOM_HTTPS"
  topic_id = oci_ons_notification_topic.budget_alert_topic.id
}

# Event alert to eventually hit a HTTP endpoint and kill all resources when $1 is spent
resource "oci_events_rule" "budget_alert_rule" {
  compartment_id = oci_identity_compartment.vps.id
  display_name   = "BudgetAlertRule"
  is_enabled     = true

  # TODO: Confirm this is the format received
  condition = jsonencode({
    "data" : {
      "budgetThreshold" : "1" # when the budget exceeds 10%
    }
  })

  actions {
    actions {
      action_type = "ONS"
      is_enabled  = true
      topic_id    = oci_ons_notification_topic.budget_alert_topic.id
    }
  }
}
