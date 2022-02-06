#!/bin/bash

ansible-galaxy collection install -r requirements.yml
ansible-galaxy role install -r requirements.yml

TF_STATE=../terraform/  ANSIBLE_HOST_KEY_CHECKING=False \
  ansible-playbook -i ./terraform-inventory \
    -u ubuntu --key-file=../terraform/ebi_gallery_key.pem \
    ebi-gallery.yaml
