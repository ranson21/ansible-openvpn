# Web Interface Role

Deploys and configures the OpenVPN web interface.

## Requirements

- Base role
- Nginx role
- Python 3.7 or later

## Role Variables

```yaml
web_interface_repo: "https://github.com/ranson21/ovpn-client-web.git"
web_interface_version: "master"
web_interface_path: "/opt/ovpn-client-web"
web_interface_user: "www-data"
web_interface_group: "www-data"
```

## Dependencies

- base
- nginx