# Oracle Cloud Free VPS

Terraform infrastructure as code and Ansible configuration for an Oracle Cloud free tier VPS, running Debian.

The configuration includes:

- Automated regular maintenance
- Automated SSL certs
- Analytics with Umami
- Hardening: SSH, NGINX, firewall, fail2ban.
- General software

## Ansible

Note: All Ansible commands need to be run from the `ansible` folder

To execute the playbook run:
`ansible-playbook ansible/run.yml`

You can use the --tags flag, to run only the selected roles (tags):
`ansible-playbook run.yml --tags="harden,nginx,analytics"`

## Terraform

Run terraform commands from terraform folder.

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

- Once Debian has finished installing, you will get kicked out
- Remove the host from ~/.ssh/known_hosts, its key fingerprint will have changed with debian OS re-install, so it'll say something malicious is happening
- Copy ssh pub key into server with `ssh-copy-id -i ~/.ssh/id_rsa.pub root@<your-ip-address>` (replace your ssh location if needed)
- If asked for a password and you used above script, it is `MoeClub.org`
- You should now be able to connect as `root` which is needed for Ansible setup

## Troubleshooting

### Provisioning

You can get a nice VPS on the Oracle free tier, but they never have capacity for it. There is a `retry_script.sh` that will help you continually retry `terraform apply`, but your best bet is to go PAYG and use budget alerts in this template. The VPS is still free, they just do not apply the same limited capacity limits.

### Server

There are some general server commands you may find useful in `CLI_CHEATSHEET.MD`

### DNS

Lookup dns with `dig` eg `dig your-domain.dev` to check if it’s resolved, if [dns checker](https://dnschecker.org) shows right value but `dig` doesn’t, try resetting dns cache with the following commands:

On macOS:
`sudo killall -HUP mDNSResponder`
On Linux:
`sudo systemd-resolve --flush-caches`

You can also try with a public resolver, eg.
`dig @8.8.8.8 your-domain.dev` to check with google

Remember that your router can cache DNS as well, so it can take a while to propagate.

### Authenticating

- `ansible_user` is set to `root`, otherwise it will default to whatever user you’re logged in as on your local machine.
- Make sure you have access to the ssh key on your local machine, if in doubt, remove the password as it can cause ansible to fail permissions.
- After `harden` role is run, you will not be able to ssh in as root anymore, you will need to ssh in as `username` you set, on port 2222.
- Make sure your infrastructure allows connecting on port 22 to begin with and port 2222 to support post-harden settings.

## TODO:

- Write some notes on `sshd`, `systemctl` & `ufw`

## Credits

Terraform based on [this repo](https://github.com/Fitzsimmons/oracle-always-free-vps?tab=readme-ov-file) by @Fitzsimmons.

Ansible based on [this repo](https://github.com/EricDriussi/host-your-own?tab=readme-ov-file) by @EricDriussi.
