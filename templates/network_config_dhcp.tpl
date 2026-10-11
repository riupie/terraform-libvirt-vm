version: 2
ethernets:
%{ for nic in interfaces ~}
  ${nic.name}:
    dhcp4: true
%{ endfor }