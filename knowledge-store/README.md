Hosted on DigitalOcean droplet created with the following parameters:
- Ubuntu 16.04 (LTS) x64 (latest version of Ubuntu tested with nixos-infect)
- User data:
  ```
  #cloud-config

  runcmd:
    - curl https://raw.githubusercontent.com/elitak/nixos-infect/master/nixos-infect | PROVIDER=digitalocean NIX_CHANNEL=nixos-20.03 bash 2>&1 | tee /tmp/infect.log
  ```
