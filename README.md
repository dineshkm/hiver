# hiver assigment
CSV server is a server that generates given number of random numbers and displays in the browser.

## Terraform
Terraform scripts under terraform folder creates the infrastructure as mentioned in 
Write a Terraform IaaC ( Infrastructure as A Code ) for the
following :
A. Create a Security Group (called prod-web-servers-sg) for
Default VPC which allows access to TCP port 80 and 443
from anywhere
B. Place the above 2 EC2 instances in the Private Subnet of
your Default VPC
C. Attach an Internet-facing NLB load balancer to both of the
EC2
D. All infrastructure should have a Security group created in
step 1A.
E. Create 2 EC2 instances of type t3.large ( prod-web-server-1
and prod-web-server-2 )

## Python Task
Script created under python folder performs the following requirement
Write a Python - Boto3 script to report all EC2 machines in a default
VPC which has an instance type as m5.large. You can assume
us-east-1 as the region where default VPC resides.
Script Output format:
Name Tag Instance ID
my-webserver-01.usw2.aws.example.com i-1234567890
my-webserver-02.usw2.aws.example.com i-478683483