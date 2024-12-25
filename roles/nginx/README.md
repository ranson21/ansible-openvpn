# Nginx Role

Installs and configures Nginx with support for Google-managed SSL certificates.

## Requirements

- Base role
- Google Cloud Platform

## Role Variables

```yaml
nginx_ssl_protocols:
  - TLSv1.2
  - TLSv1.3

nginx_ssl_ciphers:
  - ECDHE-ECDSA-AES128-GCM-SHA256
  - ECDHE-RSA-AES128-GCM-SHA256
  # ... (other ciphers)

nginx_proxy_port: 8081
```

## Dependencies

- base
