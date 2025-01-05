resource "oci_identity_compartment" "vps" {
    description = "VPS Compartment"
    name = "vps"
}

data "oci_identity_availability_domains" "test" {
    compartment_id = oci_identity_compartment.vps.id
}

resource "oci_core_vcn" "vps" {
    compartment_id = oci_identity_compartment.vps.id
    cidr_blocks = [var.cidr]
    display_name = "vps"
    dns_label = "vps"
}

resource "oci_core_internet_gateway" "vps" {
    compartment_id = oci_identity_compartment.vps.id
    vcn_id = oci_core_vcn.vps.id
    route_table_id = oci_core_vcn.vps.default_route_table_id
    enabled = true
    display_name = "vps"
}

resource "oci_core_route_table" "vps" {
    compartment_id = oci_identity_compartment.vps.id
    vcn_id = oci_core_vcn.vps.id

    display_name = "vps"
    route_rules {
        network_entity_id = oci_core_internet_gateway.vps.id
        destination_type = "CIDR_BLOCK"
        destination = "0.0.0.0/0"
    }
}

resource "oci_core_security_list" "vps" {
    compartment_id = oci_identity_compartment.vps.id
    vcn_id = oci_core_vcn.vps.id

    ingress_security_rules {
        protocol = 6
        source = "0.0.0.0/0"
        source_type = "CIDR_BLOCK"
        stateless = false
        tcp_options {
            min = 22
            max = 22
        }
    }

    ingress_security_rules {
        protocol = 1
        source = "0.0.0.0/0"
        source_type = "CIDR_BLOCK"
        stateless = false
        icmp_options {
            type = 3
            code = 4
        }
    }

    ingress_security_rules {
        protocol = 1
        source = var.cidr
        source_type = "CIDR_BLOCK"
        stateless = false
        icmp_options {
            type = 3
        }
    }

    dynamic "ingress_security_rules" {
        for_each = var.opened_ports
        iterator = port
        content {
            protocol = 6
            source = "0.0.0.0/0"
            source_type = "CIDR_BLOCK"
            stateless = true
            tcp_options {
                min = port.value
                max = port.value
            }
        }
    }

    egress_security_rules {
        destination = "0.0.0.0/0"
        destination_type = "CIDR_BLOCK"
        protocol = "all"
    }
}

resource "oci_core_subnet" "vps" {
    compartment_id = oci_identity_compartment.vps.id
    vcn_id = oci_core_vcn.vps.id
    cidr_block = var.cidr
    dns_label = "vps"
    route_table_id = oci_core_route_table.vps.id
    security_list_ids = [oci_core_security_list.vps.id]
}

module "A1-Always-Free-Instance" {
    source  = "adarobin/A1-Always-Free-Instance/oci"
    version = "0.3.0"
  
    compartment_id = oci_identity_compartment.vps.id
    availability_domain = data.oci_identity_availability_domains.test.availability_domains[0].name
    subnet_id = oci_core_subnet.vps.id

    ocpus = var.cpus
    boot_volume_size_in_gbs = var.disk_size
    hostname = var.hostname
    assign_public_ip = var.assign_public_ip
    memory_in_gbs = var.memory
    operating_system = var.os
    operating_system_version = var.os_version
    ssh_authorized_keys = var.ssh_authorized_keys
}
