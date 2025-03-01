# IAM Role for EKS Cluster
resource "aws_iam_role" "cluster-role" {
    name ="cluster-role"

    assume_role_policy = jsonencode({
        Version ="2012-10-17"
        Statement =[
            {
                Effect ="Allow"
                Principal={
                    Service ="eks.amazonaws.com"
                }
                Action ="sts:AssumeRole"
            }
        ]
    })
}

# Attach necessary policies to the cluster role
resource "aws_iam_role_policy_attachment" "cluster-policy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    role = aws_iam_role.cluster-role.name
}

# I AM Role for the EKS Node Group
resource "aws_iam_role" "node_role"{
    name = "node-role"

    assume_role_policy = jsonencode({
        Version ="2012-10-17"
        Statement =[
            {
                Effect = "Allow"
                Principal ={
                    Service ="ec2.amazonaws.com"
                }
                Action ="sts:AssumeRole"
            }
        ]
    })
}  

#Attach necessary policies to the node role
resource "aws_iam_role_policy_attachment" "node_policy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    role = aws_iam_role.node_role.name
}

resource "aws_iam_role_policy_attachment" "cni-policy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy" #Updated policy ARN
    role = aws_iam_role.node_role.name
}

resource "aws_iam_role_policy_attachment" "registry-policy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    role = aws_iam_role.node_role.name
}
  
# EKS Cluster
resource "aws_eks_cluster" "eks_cluster" {
name = "k8-cluster" 
role_arn = aws_iam_role.cluster-role.arn
version = "1.30"

vpc_config {
  subnet_ids = ["subnet-0493f37100fc069ef","subnet-049a6c3447376ae5e"]
  security_group_ids = ["sg-0f9d3016e34486528"]
}

depends_on = [aws_iam_role_policy_attachment.cluster-policy]
}

# EKS Node group
resource "aws_eks_node_group" "k8-cluster-node-group" {
cluster_name = aws_eks_cluster.eks_cluster.name
node_group_name = "k8-cluster-node-group"
node_role_arn = aws_iam_role.node_role.arn
subnet_ids =   ["subnet-0493f37100fc069ef","subnet-049a6c3447376ae5e"]

scaling_config {
  desired_size = 3
  min_size = 2
  max_size = 5
}
depends_on =[aws_iam_role_policy_attachment.node_policy]
}