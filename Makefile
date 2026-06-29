.PHONY: ping preflight syntax check site t7-root

ping:
	ansible all -m ping

preflight:
	ansible-playbook playbooks/00-preflight.yml

syntax:
	ansible-playbook playbooks/site.yml --syntax-check
	ansible-playbook playbooks/10-t7-root.yml --syntax-check

check:
	ansible-playbook playbooks/site.yml --check

site:
	ansible-playbook playbooks/site.yml

t7-root:
	ansible-playbook playbooks/10-t7-root.yml -e excalibur_t7_confirm_destroy=true

