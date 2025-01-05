# oci-free-vps

Infrastructure for an Oracle Cloud free tier VPS

Terraform built upon [this repo](https://github.com/Fitzsimmons/oracle-always-free-vps?tab=readme-ov-file)
Ansible built upon [this repo](https://github.com/EricDriussi/host-your-own?tab=readme-ov-file)

### Ansible

Note: All Ansible commands need to be run from the `ansible`` folder

To execute the playbook run:
`ansible-playbook ansible/run.yml`

You can use the --tags flag, to run only the selected roles (tags):
`ansible-playbook ansible/run.yml --tags="harden,nginx,analytics"`

### TODO:

- Ensure an ssh user is created when instance is created
- TODO: Replace the below 'geordie' with a variable of some sort
- Ensure works on both debian or ubuntu

```
provisioner "remote-exec" {
    inline = [
      "sudo useradd -m geordie",  # Create the geordie user
      "sudo usermod -aG sudo geordie",  # Add geordie to the sudo group
      "sudo mkdir -p /home/geordie/.ssh",  # Create the .ssh directory for geordie
      "sudo cp /home/ubuntu/.ssh/authorized_keys /home/geordie/.ssh/authorized_keys",  # Copy SSH keys from ubuntu user
      "sudo chown -R geordie:geordie /home/geordie/.ssh",  # Fix permissions for .ssh folder
      "sudo chmod 700 /home/geordie/.ssh",  # Secure the .ssh directory
      "sudo chmod 600 /home/geordie/.ssh/authorized_keys",  # Secure the authorized_keys file
      "sudo passwd geordie"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"  # Or the user you're connecting as (e.g., ec2-user, ubuntu)
      private_key = file("path_to_your_private_key.pem")  # Path to your private key
      host        = self.public_ip
    }
```
