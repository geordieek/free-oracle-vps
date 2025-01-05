# oci-free-vps

Infrastructure for an Oracle Cloud free tier VPS

Built upon [this helpful repo](https://github.com/Fitzsimmons/oracle-always-free-vps?tab=readme-ov-file) by @Fitzsimmons

### Ansible

```bash
# check connectivity
ansible all -i ansible/inventories/hosts.yml -m ping
# run main setup
ansible-playbook -i ansible/inventories/hosts.yml ansible/main.yml
```
