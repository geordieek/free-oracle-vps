variable "hostname" {
    type = string
    default = "vps"
}

variable "memory" {
    type = number
    default = 24
}

variable "os" {
    type = string
    default = "Canonical Ubuntu"
}

variable "os_version" {
    type = string
    default = "22.04 Minimal aarch64"
}

variable "ssh_authorized_keys" {
    type = string
}

variable "assign_public_ip" {
    type = bool
    default = true
}

variable "disk_size" {
    type = number
    default = 200
}

variable "cpus" {
    type = number
    default = 4
}

variable "cidr" {
    type = string
    default = "192.168.17.0/24"
}

variable "opened_ports" {
    default = [80, 443]
}
