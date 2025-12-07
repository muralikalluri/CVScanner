param (
    [Parameter(Mandatory = $true)]
    [string]$KeyPairName
)

$ErrorActionPreference = "Stop"

Write-Host "Creating Security Group for Kafka..."
$SgId = aws ec2 create-security-group --group-name KafkaSG --description "Security group for Kafka Broker" --output text --query 'GroupId'
Write-Host "Security Group ID: $SgId"

Write-Host "Authorizing SSH (22) and Kafka (9092)..."
aws ec2 authorize-security-group-ingress --group-id $SgId --protocol tcp --port 22 --cidr 0.0.0.0/0 | Out-Null
aws ec2 authorize-security-group-ingress --group-id $SgId --protocol tcp --port 9092 --cidr 0.0.0.0/0 | Out-Null
aws ec2 authorize-security-group-ingress --group-id $SgId --protocol tcp --port 2181 --cidr 0.0.0.0/0 | Out-Null

Write-Host "Launching EC2 Instance (Amazon Linux 2023)..."
# AMI ID for Amazon Linux 2023 in us-east-1
$AmiId = "ami-0ae8f15ae66fe8cda"

# Read user data file
$UserData = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes((Get-Content -Path "kafka-user-data.sh" -Raw)))

$InstanceId = aws ec2 run-instances `
    --image-id $AmiId `
    --count 1 `
    --instance-type t2.small `
    --key-name $KeyPairName `
    --security-group-ids $SgId `
    --user-data $UserData `
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=CVScanner-Kafka}]' `
    --output text --query 'Instances[0].InstanceId'

Write-Host "Instance launched: $InstanceId"
Write-Host "Waiting for instance to run..."
aws ec2 wait instance-running --instance-ids $InstanceId

$PublicIp = aws ec2 describe-instances --instance-ids $InstanceId --output text --query 'Reservations[0].Instances[0].PublicIpAddress'

Write-Host "Kafka Broker deployed at: $PublicIp"
Write-Host "Note: It may take a few minutes for Kafka to install and start."
Write-Host "Connection String: ${PublicIp}:9092"
