output "ec2_id" {
  description = "The ID of the instance"
  value       = module.ec2.id
}

output "ec2_arn" {
  description = "The ARN of the instance"
  value       = module.ec2.arn
}

output "ec2_capacity_reservation_specification" {
  description = "Capacity reservation specification of the instance"
  value       = module.ec2.capacity_reservation_specification
}

output "ec2_instance_state" {
  description = "The state of the instance. One of: `pending`, `running`, `shutting-down`, `terminated`, `stopping`, `stopped`"
  value       = module.ec2.instance_state
}

output "ec2_primary_network_interface_id" {
  description = "The ID of the instance's primary network interface"
  value       = module.ec2.primary_network_interface_id
}

output "ec2_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block"
  value       = module.ec2.tags_all
}

output "ebs_volume_device" {
  description = "The requested device name for the EBS volume when attached to the EC2 instance"
  value       = aws_volume_attachment.ebi-volume_attachment.device_name
}

output "elastic_ip" {
  description =  "The Elastic IP address attached to the EC2 instance"
  value       = aws_eip.ebi-gallery-ip.public_ip
}

output "private_key" {
  description = "The filename of the SSH private key, created locally"
  value       = local_file.private_key.filename
}
