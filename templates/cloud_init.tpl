#cloud-config

package_upgrade: false

packages:
  - iotop
  - python3
  - qemu-guest-agent

runcmd:
${runcmd}

fqdn: ${hostname}

users:
  - name: ${ssh_admin}
    gecos: CI User
    lock-passwd: false
    sudo: ALL=(ALL) NOPASSWD:ALL
    system: False
    ssh_authorized_keys: ${ssh_keys}
    shell: /bin/bash
%{ if local_admin != "" }
  - name: ${local_admin}
    gecos: Local admin (no SSH)
    lock-passwd: false
    sudo: ALL=(ALL) ALL
    passwd: ${local_admin_passwd}
    shell: /bin/bash
%{ endif }

write_files:
  - path: /etc/ssh/sshd_config
    content: |
        Port 22
        Protocol 2
        HostKey /etc/ssh/ssh_host_rsa_key
        HostKey /etc/ssh/ssh_host_dsa_key
        HostKey /etc/ssh/ssh_host_ecdsa_key
        HostKey /etc/ssh/ssh_host_ed25519_key
        UsePrivilegeSeparation yes
        KeyRegenerationInterval 3600
        ServerKeyBits 1024
        SyslogFacility AUTH
        LogLevel INFO
        LoginGraceTime 120
        PermitRootLogin no
        StrictModes yes
        RSAAuthentication yes
        PubkeyAuthentication yes
        IgnoreRhosts yes
        RhostsRSAAuthentication no
        HostbasedAuthentication no
        PermitEmptyPasswords no
        ChallengeResponseAuthentication no
        X11Forwarding yes
        X11DisplayOffset 10
        PrintMotd no
        PrintLastLog yes
        TCPKeepAlive yes
        AcceptEnv LANG LC_*
        Subsystem sftp /usr/lib/openssh/sftp-server
        UsePAM yes
        AllowUsers ${ssh_admin}

growpart:
    mode: auto
    devices:
      - "/"

resize_rootfs: true

timezone: ${time_zone}


# Disable IPv6
%{ if disable_ipv6 ~}
write_files:
  - path: /etc/sysctl.d/10-disable-ipv6.conf
    permissions: '0644'
    owner: root:root
    content: |
      net.ipv6.conf.all.disable_ipv6 = 1
      net.ipv6.conf.default.disable_ipv6 = 1
      net.ipv6.conf.lo.disable_ipv6 = 1
%{ endif ~}