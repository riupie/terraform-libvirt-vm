version: 2
ethernets:
%{ for idx, nic in interfaces ~}
  %{ if contains(keys(nic), "name") && nic.name != null }
  ${nic.name}:
  %{ else }
  eth${idx}:
  %{ endif }
    dhcp4: false
    addresses: [${nic.address}/24]
%{ if contains(keys(nic), "gateway") && nic.gateway != null }
    gateway4: ${nic.gateway}
%{ endif }
%{ if contains(keys(nic), "dns") && nic.dns != null }
    nameservers:
      addresses:
%{ for ns in nic.dns ~}
        - ${ns}
%{ endfor ~}
%{ endif }
%{ endfor ~}
