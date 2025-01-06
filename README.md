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
- Write notes explaining manual debian install, this currently won't work with ubuntu
- Write notes on `sshd`, `systemctl` & `ufw`
