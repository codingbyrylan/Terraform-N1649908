resource "null_resource" "ansible_provisioner" {
  count = length(module.linux_vms.linux_vm_fqdns)

  triggers = {
    always_run = "${timestamp()}"
  }

  connection {
    type        = "ssh"
    user        = "rylan1402"
    private_key = file("/Users/n01649908/.ssh/id_rsa")
    host        = element(module.linux_vms.linux_vm_fqdns, count.index)
    timeout     = "1m"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Starting provisioning...' > /tmp/provisioner.log 2>&1",
      
      # Install Python 2 first and set as default
      "sudo yum install -y python2 >> /tmp/provisioner.log 2>&1",
      "sudo alternatives --set python /usr/bin/python2 >> /tmp/provisioner.log 2>&1",  # Set Python 2 as default for python command
      "/usr/bin/python2 --version >> /tmp/provisioner.log 2>&1",  # Verify Python 2 installation

      # Update CentOS repositories
      "sudo sed -i 's|^mirrorlist=|#mirrorlist=|g' /etc/yum.repos.d/CentOS-*.repo >> /tmp/provisioner.log 2>&1",
      "sudo sed -i 's|^#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*.repo >> /tmp/provisioner.log 2>&1",
      "sudo yum clean all >> /tmp/provisioner.log 2>&1",

      # Fix Python version for yum and related scripts
      "sudo sed -i '1s|^#!.*|#!/usr/bin/python2|' /usr/bin/yum >> /tmp/provisioner.log 2>&1",
      "sudo sed -i '1s|^#!.*|#!/usr/bin/python2|' /usr/libexec/urlgrabber-ext-down >> /tmp/provisioner.log 2>&1",

      # Install development tools and dependencies for Python 3
      "sudo yum groupinstall -y 'Development Tools' >> /tmp/provisioner.log 2>&1",
      "sudo yum install -y gcc openssl-devel bzip2-devel libffi-devel >> /tmp/provisioner.log 2>&1",

      # Download, compile and install Python 3.8
      "cd /usr/src",
      "sudo wget https://www.python.org/ftp/python/3.8.12/Python-3.8.12.tgz >> /tmp/provisioner.log 2>&1",
      "sudo tar xzf Python-3.8.12.tgz >> /tmp/provisioner.log 2>&1",
      "cd Python-3.8.12",
      "sudo ./configure --enable-optimizations >> /tmp/provisioner.log 2>&1",
      "sudo make altinstall >> /tmp/provisioner.log 2>&1",
      
      # Set Python 3.8 as python3
      "sudo ln -sf /usr/local/bin/python3.8 /usr/bin/python3 >> /tmp/provisioner.log 2>&1",  # Set Python 3.8 as python3
      "sudo ln -sf /usr/local/bin/python3.8 /usr/bin/python >> /tmp/provisioner.log 2>&1",  # Set Python 3.8 as default python
      
      # Verify installations
      "/usr/local/bin/python3.8 --version >> /tmp/provisioner.log 2>&1",  # Verify Python 3.8 installation
      "python --version >> /tmp/provisioner.log 2>&1",  # Verify default python command
      "python3 --version >> /tmp/provisioner.log 2>&1",  # Verify python3 command
      "python2 --version >> /tmp/provisioner.log 2>&1",  # Verify python2 command

      "echo 'Provisioning complete.' >> /tmp/provisioner.log 2>&1"
    ]
  }

  provisioner "local-exec" {
    command = <<EOT
      ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook  \
      -i ${element(module.linux_vms.linux_vm_fqdns, count.index)}, \
      -u rylan1402 \
      --private-key /Users/n01649908/.ssh/id_rsa \
      /Users/n01649908/automation/ansible/n01649908-playbook.yml
    EOT
  }

  depends_on = [module.linux_vms]
}
