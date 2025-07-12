# This file uses Terraform's template syntax for variable interpolation and loops.
version: 2
ethernets:
%{ for nic in interfaces ~}
  ${nic.name}:
    dhcp4: false
    addresses: [${nic.address}/24]
%{ if contains(keys(nic), "gateway") }
    gateway4: ${nic.gateway}
%{ endif }
%{ if contains(keys(nic), "dns") }
    nameservers:
      addresses:
%{ for ns in nic.dns ~}
        - ${ns}
%{ endfor }
%{ endif }
%{ endfor }