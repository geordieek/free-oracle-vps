# oci-free-vps

Infrastructure and configuration for an Oracle Cloud free tier VPS, running Debian.

Terraform built upon [this repo](https://github.com/Fitzsimmons/oracle-always-free-vps?tab=readme-ov-file).

Ansible built upon [this repo](https://github.com/EricDriussi/host-your-own?tab=readme-ov-file).

### TODO:

- Write some notes on `sshd`, `systemctl` & `ufw`
- Organise terraform into its own folder

## Ansible

Note: All Ansible commands need to be run from the `ansible` folder

To execute the playbook run:
`ansible-playbook ansible/run.yml`

You can use the --tags flag, to run only the selected roles (tags):
`ansible-playbook ansible/run.yml --tags="harden,nginx,analytics"`

## Terraform

- Currently terraform needs to be run from root, eventually it will go into a terraform folder.

## Debian Install

This relies on a Debian install which isn't offered on Oracle. 

- First provision an Ubuntu instance.
- ssh in as `ubuntu` user
- Install Debian with this script

```bash
sudo chown -R ubuntu /backup
sudo -s
bash <(wget --no-check-certificate -qO- 'https://moeclub.org/attachment/LinuxShell/InstallNET.sh') -d 12 -v 64 -a -firmware
// default pass MoeClub.org
```

- You will get kicked out
- Remove the host from ~/.ssh/known_hosts, its key fingerprint will have changed with debian OS re-install, so it'll say something malicious is happening
- Copy ssh pub key into server with `ssh-copy-id -i ~/.ssh/id_rsa.pub root@168.138.4.151` (replace your ssh location if needed)
- You should now be able to connect as `root` which is needed for Ansible setup

## Troubleshooting

### DNS

Lookup dns with `dig` eg `dig geordie.dev` to check if it’s resolved, if [dns checker](TODO) shows right value but dig doesn’t, try resetting dns cache

On macOS:
`sudo killall -HUP mDNSResponder`
On Linux:
`sudo systemd-resolve --flush-caches`

You can also try with a public resolver, eg.
`dig @8.8.8.8 geordie.dev` to check with google

Remember that your router can cache DNS as well, so it can take a while to propagate.

### Authenticating

- `ansible_user` is set to `root`, otherwise it will default to whatever user you’re logged in as on your local machine.
- Make sure you have access to the ssh key on your local machine, if in doubt, remove the password as it can cause ansible to fail permissions.
- After `harden` role is run, you will not be able to ssh in as root anymore, you will need to ssh in as `username` you set, on port 2222.
- Make sure your infrastructure allows connecting on port 22 to begin with and port 2222 to support post-harden settings.


