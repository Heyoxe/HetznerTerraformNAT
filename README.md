# Stack
**THIS IS NOT A PRODUCTION-READY SETUP, IT IS NOT SECURE, IT DOES NOT WORK AS IT SHOULD, DO NOT USE**
Simple Terraform repo to provision and configure servers routed through a NAT gateway on [Hetzner](https://www.hetzner.com/).

This will setup:
- 1x Private Network
- 2x CX11 Servers (one gateway and one client)
- 2x Firewall (one for the Gateway and one for the clients)

To connect to the clients you MUST first connect trough the gateway. You could also disable the SSH access to the gateway add instead use a bastion server which should be added to the same private network
Every outgoing connection from the clients *should* go through the gateway if I didn't mess up anything

## Commands
```
$ curl 'https://api64.ipify.org?format=json'
$ mtr google.com
$ traceroute google.com
```

## Upgrades
- You could probably replace the hard-coded ip ranges etc by variables in Terraform
- You should also look at completely disabling the public interface of the clients but that doesn't work at all atm

## Sources
https://docs.digitalocean.com/products/networking/vpc/resources/droplet-as-gateway/
https://www.mybluelinux.com/debian-permanent-static-routes/
https://community.hetzner.com/tutorials/how-to-route-cloudserver-over-private-network-using-pfsense-and-hcnetworks
