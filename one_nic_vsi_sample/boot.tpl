#cloud-config
ssh_pwauth: True
ssh_authorized_keys:
  - ${ssh_key}
