# OpenVPN Role

Installs and configures OpenVPN server.

## Requirements

- Base role
- Easy-RSA package

## Role Variables

```yaml
openvpn_port: 1194
openvpn_protocol: udp
openvpn_network: "10.8.0.0"
openvpn_netmask: "255.255.255.0"
```

## Dependencies

- base