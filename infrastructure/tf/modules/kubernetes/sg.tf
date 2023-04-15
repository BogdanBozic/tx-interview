### Master Node ###

resource "aws_security_group" "goldbach_master" {
  name        = "goldbach"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.goldbach.id
}

resource "aws_vpc_security_group_ingress_rule" "goldbach_master_kubectl" {
  security_group_id = aws_security_group.goldbach_master.id

  description = "Allow public inbound traffic from user IP only."
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
  #  cidr_ipv4   = "${chomp(data.http.self-ip.response_body)}/32"
  cidr_ipv4 = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "eks_cluster_outbound" {
  security_group_id = aws_security_group.goldbach_master.id

  description = "Allow all outbound traffic."
  from_port   = 0
  to_port     = 0
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"
}

#resource "aws_vpc_security_group_ingress_rule" "eks_cluster_vpc" {
#  security_group_id = aws_security_group.goldbach_master.id
#
#  description                  = "Allow all traffic within VPC."
#  from_port                    = 0
#  to_port                      = 65535
#  ip_protocol                  = "tcp"
#  referenced_security_group_id = aws_security_group.goldbach_worker.id
#}

### End Master Node ###

### Worker Node ###

resource "aws_security_group" "goldbach_worker" {
  name        = "goldbach_worker"
  description = "Security group for all worker nodes in the cluster"
  vpc_id      = aws_vpc.goldbach.id
}

#resource "aws_vpc_security_group_ingress_rule" "goldbach_worker_all_vpc" {
#  security_group_id = aws_security_group.goldbach_worker.id
#
#  description                  = "Allow all traffic within VPC."
#  from_port                    = 0
#  to_port                      = 65535
#  ip_protocol                  = "tcp"
#  referenced_security_group_id = aws_security_group.goldbach_worker.id
#}

#resource "aws_vpc_security_group_ingress_rule" "goldbach_worker_allow_inbound_from_master" {
#  security_group_id = aws_security_group.goldbach_worker.id
#
#  description                  = "Allow all traffic within VPC."
#  from_port                    = 0
#  to_port                      = 65535
#  ip_protocol                  = "tcp"
#  referenced_security_group_id = aws_security_group.goldbach_master.id
#}

#resource "aws_vpc_security_group_ingress_rule" "goldbach_worker_inbound_from_control_plane" {
#  security_group_id = aws_security_group.goldbach_worker.id
#
#  description                  = "Allow incoming traffic from the control plane"
#  from_port                    = 10250
#  to_port                      = 10255
#  ip_protocol                  = "tcp"
#  referenced_security_group_id = aws_security_group.goldbach_master.id
#}

resource "aws_vpc_security_group_egress_rule" "goldbach_worker_outbound_all" {
  security_group_id = aws_security_group.goldbach_worker.id

  description = "Allow outgoing traffic for worker nodes"
  from_port   = 0
  to_port     = 0
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"
}

### End Worker Node ###
