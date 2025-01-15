# 🔐 OpenVPN Server Image

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

This repository contains infrastructure as code for deploying a secure OpenVPN server on Google Cloud Platform (GCP) with a web-based management interface. It uses Packer for image building, Ansible for configuration management, and integrates with Terraform for deployment.

## 🌟 Features

- **Automated Deployment**: Full automation of OpenVPN server setup
- **Web Interface**: User-friendly web portal for managing VPN users
- **Google Cloud Integration**:
  - Managed SSL certificates
  - Cloud IAP integration
  - Static IP management
- **Security First**:
  - Modern cipher suites
  - Automatic security updates
  - Principle of least privilege
- **Monitoring Ready**: Built-in health checks and monitoring endpoints

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- **Required Tools**:
  ```bash
  ansible >= 2.9.0
  packer >= 1.7.0
  gcloud CLI
  terraform >= 1.0.0
  ```

- **GCP Setup**:
  - A GCP project with billing enabled
  - Service account with necessary permissions
  - gcloud CLI configured with your project

## 🚀 Quick Start

1. **Clone the Repository**
   ```bash
   git clone https://github.com/yourusername/openvpn-automation.git
   cd openvpn-automation
   ```

2. **Initialize the Project**
   ```bash
   # Install dependencies and set up configuration files
   make init

   # View available commands
   make help
   ```

3. **Configure Variables**
   ```bash
   # Edit your configuration (created during init)
   vi inventory/group_vars/all.yml
   vi packer/vars.pkr.hcl
   ```

4. **Validate and Build**
   ```bash
   # Run validation checks
   make validate
   
   # Build the image (using default variables)
   make build-image
   
   # Or build with custom variables
   GCP_PROJECT=your-project-id GCP_ZONE=us-central1-a NETWORK=default make build-image
   
   # For detailed build logs
   make build-image-debug
   ```

5. **Deploy with Terraform**
   ```bash
   # Example Terraform usage (assuming you have a Terraform configuration)
   cd terraform
   terraform init
   terraform apply \
     -var="project_id=your-project-id" \
     -var="region=us-central1" \
     -var="domain=vpn.example.com"
   ```

## 🔧 Available Make Commands

The project includes a Makefile with various useful commands to help you develop, test, and deploy:

```bash
# Show all available commands
make help

# Common commands:
make init          # Initialize the project
make validate      # Run all validation checks
make build-image   # Build the GCP image
make test         # Run tests
make lint         # Run linting
make clean        # Clean up generated files
make logs         # View relevant logs
```

You can override default variables when running commands:
```bash
GCP_PROJECT=my-project GCP_ZONE=us-west1-a make build-image
```

Available variables:
- `GCP_PROJECT`: Your Google Cloud project ID
- `GCP_REGION`: GCP region (default: us-central1)
- `GCP_ZONE`: GCP zone (default: us-central1-a)
- `NETWORK`: Network name (default: default)
- `DOMAIN`: Your domain name

## 🛠️ Development Setup

To set up a development environment:

1. **Install Development Tools**
   ```bash
   # Install Ansible Lint
   pip install ansible-lint
   ```

2. **Run Tests**
   ```bash
   # Run Ansible playbook syntax check
   ansible-playbook --syntax-check playbooks/vpn_server.yml

   # Run full test suite
   cd tests
   ansible-playbook -i inventory test.yml
   ```

## 📖 Documentation

### Component Details

#### Ansible Roles

- **base**: Core system configuration
  - Package installation
  - System hardening
  - Network configuration

- **nginx**: Web server setup
  - SSL configuration
  - Reverse proxy
  - Security headers

- **openvpn**: VPN server configuration
  - Certificate management
  - Network routing
  - Client configuration

- **web_interface**: Management portal
  - User authentication
  - Client certificate generation
  - Usage statistics

### Configuration Options

| Variable       | Description                | Default       | Required |
| -------------- | -------------------------- | ------------- | -------- |
| `project_id`   | GCP Project ID             | -             | Yes      |
| `region`       | GCP Region                 | `us-central1` | Yes      |
| `network_name` | VPC Network Name           | `vpn-network` | No       |
| `domain`       | Domain for SSL Certificate | -             | Yes      |

## 🔄 Updating

To update an existing deployment:

1. **Update Repository**
   ```bash
   git pull origin master
   ```

2. **Rebuild Image**
   ```bash
   cd packer
   packer build -force vars.pkr.hcl
   ```

3. **Apply Changes**
   ```bash
   # If using Terraform
   terraform apply
   ```

## 🐛 Troubleshooting

Common issues and solutions:

### Image Build Failures
```bash
# Check Packer logs
PACKER_LOG=1 packer build vars.pkr.hcl

# Validate Packer template
packer validate vars.pkr.hcl
```

### Deployment Issues
```bash
# Check instance logs
gcloud compute instances get-serial-port-output INSTANCE_NAME

# SSH into instance
gcloud compute ssh INSTANCE_NAME
```

### Web Interface Issues
```bash
# Check nginx logs
sudo tail -f /var/log/nginx/error.log

# Check web interface service
sudo systemctl status vpn-web
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👤 Author

Abigail Ranson
- Website: [abbyranson.com](https://abbyranson.com)
- GitHub: [@ranson21](https://github.com/ranson21)

## 🙏 Acknowledgements

- [OpenVPN Community](https://openvpn.net/)
- [Google Cloud Platform](https://cloud.google.com/)
- [Ansible Community](https://www.ansible.com/)

## 💬 Support

For support, please:
1. Check the [Issues](https://github.com/yourusername/openvpn-automation/issues) page
2. Create a new issue if needed
3. Join our [Discord/Slack] community

---
Created and maintained with ❤️ by [@ranson21](https://github.com/ranson21)