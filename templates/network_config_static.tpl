#cloud-config
version: 2
ethernets:
%{ for nic in interfaces ~}
  ${nic.name}:
    dhcp4: no
    addresses: [${nic.address}/24]
%{ if contains(keys(nic), "gateway") }
    gateway4: ${nic.gateway}
%{ endif }
%{ if contains(keys(nic), "dns") }
    nameservers:
      addresses:
%{ for dns in nic.dns ~}
        - ${dns}
%{ endfor ~}
%{ endif }
%{ endfor ~}