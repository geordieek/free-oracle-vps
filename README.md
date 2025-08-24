# Oracle Cloud Free VPS

Terraform infrastructure as code and Ansible configuration for an Oracle Cloud free tier VPS, running Debian.

The configuration includes:

- Automated regular maintenance
- Automated SSL certs
- Analytics with Umami
- Code-server (VS Code in browser)
- Hardening: SSH, NGINX, firewall, fail2ban.
- General software

## Ansible

Note: All Ansible commands need to be run from the `ansible` folder

To execute the playbook run:
`ansible-playbook ansible/run.yml`

You can use the --tags flag, to run only the selected roles (tags):
`ansible-playbook run.yml --tags="harden,nginx,analytics"`

### Code-server

It is recommended to use Tailscale to access code-server. This is the default behaviour and set with `expose_code_server_tailscale: true` in `ansible/.env.yml`. You will then be able to access your code-server at your tailscale hostname eg. `my-server.tail423678ad.ts.net`.

If you set `expose_code_server_public: true` in `ansible/.env.yml` and configure your DNS records, you can access code-server at `https://code.your-domain.com`. In the current config, nginx only serves `code.your-domain.com` when a Cloudflare header is present, and requires a Cloudflare header to access it, so you will need to either setup Cloudflare proxies (free), change it or use Tailscale.

The code-server password is set in `ansible/.env.yml` as `code_server_password`.

Copy your VS Code settings to `ansible/roles/code-server/files/settings.json` to copy them to the server.

NOTE: If you're on an iPad, you may have issues accessing the tailscale hostname due to iOS DNS resolution intercepting tailscale. See this issue here: https://github.com/tailscale/tailscale/issues/12563. The provided fix worked for me.

### Cloudflare

- If you want to expose code server publicly, I strongly suggest adding extra security beyond just a password. This setup uses Cloudflare Access to gate access to code server, as such, you will need to setup cloudflare proxies to access it.
- The `code` subdomain is proxied and gated by Cloudflare Access, and nginx requires a Cloudflare header to access it.

### Tailscale

Set the tailscale envs from `ansible/.example-env.yml` in `ansible/.env.yml` to enable Tailscale auto-login during Ansible runs:

Notes:

- UDP 41641 is allowed in both UFW and OCI security list for peer connectivity.
- Existing SSH (`{{ ports.ssh }}`) and Mosh UDP (60000-61000) remain allowed.
- Enabling `tailscale_enable_ssh: true` lets you SSH over your tailnet.

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

- If nginx is running but you can't access your website. You can reconfigure and restart it with `ansible-playbook run.yml --skip-tags user --tags nginx`

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

### Cloudflare (public + 2FA for code-server)

- We use Cloudflare as reverse proxy for code server. `your-domain.com` stays public; only `code.your-domain.com` is gated with Cloudflare Access.
- SSL:
  - Cloudflare serves edge certs for `*.your-domain.com`.
  - Origin certs (Let’s Encrypt) are issued by the nginx role; set `expose_code_server_public: true` in `ansible/.env.yml` and run the nginx role.
- Access:
  - App 1 (bypass): host `code.your-domain.dev`, path `/.well-known/acme-challenge/*`, action Bypass → Everyone (for ACME).
  - App 2 (protected): host `code.your-domain.dev`, path `/`, action Allow → Include your email, Require OTP/MFA.
- NGINX hardening: the `code` vhost includes an auto-generated Cloudflare IP allowlist, then `deny all` to prevent direct origin hits.

### Authenticating

- `ansible_user` is set to `root`, otherwise it will default to whatever user you’re logged in as on your local machine.
- Make sure you have access to the ssh key on your local machine, if in doubt, remove the password as it can cause ansible to fail permissions.
- After `harden` role is run, you will not be able to ssh in as root anymore, you will need to ssh in as `username` you set, on port 2222.
- Make sure your infrastructure allows connecting on port 22 to begin with and port 2222 to support post-harden settings.

## TODO:

- Write some notes on `sshd`, `systemctl` & `ufw`
- Add 2FA with 2fauth or authelia

## Credits

Terraform based on [this repo](https://github.com/Fitzsimmons/oracle-always-free-vps?tab=readme-ov-file) by @Fitzsimmons.

Ansible based on [this repo](https://github.com/EricDriussi/host-your-own?tab=readme-ov-file) by @EricDriussi.
