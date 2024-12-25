# Base Role

Configures basic system settings and installs required packages.

## Requirements

- Debian 11 or later
- Python 3

## Role Variables

```yaml
base_packages:
  - openvpn
  - easy-rsa
  - nginx
  - python3-pip
  - git
  - make
  - curl
  - iptables-persistent

enable_ip_forwarding: true
```

## Dependencies

None
