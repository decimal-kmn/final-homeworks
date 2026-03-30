output "ansible_inventory" {
  value = <<EOF
[master]
${yandex_compute_instance.master.network_interface[0].nat_ip_address}

[workers]
%{ for w in yandex_compute_instance.workers ~}
${w.network_interface[0].nat_ip_address}
%{ endfor ~}
EOF
}
