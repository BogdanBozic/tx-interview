resource "aws_vpc" "goldbach" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "goldbach"
  }
}

### Control Plane ###

resource "aws_subnet" "goldbach_control_plane" {
  count = 2

  availability_zone = data.aws_availability_zones.azs.names[count.index]
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = aws_vpc.goldbach.id

  tags = {
    Name = "goldbach-control-plane-${count.index}"
  }
}

resource "aws_internet_gateway" "goldbach" {
  vpc_id = aws_vpc.goldbach.id
  tags = {
    Name = "goldbach"
  }
}

resource "aws_route_table" "goldbach" {
  vpc_id = aws_vpc.goldbach.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.goldbach.id
  }

  tags = {
    Name = "goldbach"
  }
}

resource "aws_route_table_association" "goldbach" {
  count = 2

  subnet_id      = aws_subnet.goldbach_control_plane[count.index].id
  route_table_id = aws_route_table.goldbach.id
}

### End Control Plane ###

### Worker Nodes ###

resource "aws_subnet" "goldbach_workers" {
  count = 2

  availability_zone = data.aws_availability_zones.azs.names[count.index]
  cidr_block        = "10.0.${count.index + 10}.0/24"
  vpc_id            = aws_vpc.goldbach.id
  tags = {
    "kubernetes.io/cluster/${aws_eks_cluster.goldbach.name}" = "shared"
  }

}

resource "aws_nat_gateway" "goldbach" {
  count         = 2
  allocation_id = aws_eip.goldbach[count.index].id
  subnet_id     = aws_subnet.goldbach_control_plane[count.index].id
  depends_on    = [aws_internet_gateway.goldbach]

  tags = {
    Name = "goldbach-${count.index}"
  }
}

resource "aws_eip" "goldbach" {
  depends_on = [aws_internet_gateway.goldbach]
  count      = 2
  vpc        = true

  tags = {
    Name = "goldbach-${count.index}"
  }
}

resource "aws_route_table" "goldbach_worker" {
  count  = 2
  vpc_id = aws_vpc.goldbach.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.goldbach[count.index].id
  }

  tags = {
    Name = "goldbach-worker-${count.index}"
  }
}

resource "aws_route_table_association" "goldbach_worker" {
  count          = 2
  subnet_id      = aws_subnet.goldbach_workers[count.index].id
  route_table_id = aws_route_table.goldbach_worker[count.index].id
}

### End Worker Nodes ###