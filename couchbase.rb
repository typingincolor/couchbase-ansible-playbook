require 'cfndsl'

CloudFormation {
  Description "Couchbase test"

  VPC(:VPC) {
    EnableDnsSupport true
    EnableDnsHostnames true
    CidrBlock "172.30.0.0/16"
    addTag("Name", "Couchbase VPC")
  }

  InternetGateway(:InternetGateway) {
    addTag("Name", "Couchbase VPC Gateway")
  }

  VPCGatewayAttachment(:GatewayToInternet) {
    VpcId Ref(:VPC)
    InternetGatewayId  Ref(:InternetGateway)
  }

  Subnet(:subnet) {
      VpcId Ref(:VPC)
      CidrBlock "172.30.0.0/24"
      addTag("Name", "Couchbase vpc subnet")
  }

  RouteTable(:routeTable) {
      VpcId Ref(:VPC)
      addTag("Name", "Couchbase subnet route table")
  }

  SubnetRouteTableAssociation(:routeTableAssociation) {
    SubnetId Ref(:subnet)
    RouteTableId Ref(:routeTable)
  }

  Route(:gatewayRoute) {
    DependsOn :GatewayToInternet
    RouteTableId Ref(:routeTable)
    DestinationCidrBlock "0.0.0.0/0"
    GatewayId Ref(:InternetGateway)
  }

  EC2_SecurityGroup(:CouchbaseSecurityGroup) {
    GroupDescription "Security policies for Couchbase servers"
    VpcId Ref(:VPC)
  }

  EC2_SecurityGroupIngress(:CouchbaseGroupIngress11209) {
    GroupId Ref(:CouchbaseSecurityGroup)
    IpProtocol "tcp"
    FromPort 11209
    ToPort 11209
    CidrIp "172.30.0.0/24"
  }

  EC2_SecurityGroupIngress(:CouchbaseGroupIngress11215) {
    GroupId Ref(:CouchbaseSecurityGroup)
    IpProtocol "tcp"
    FromPort 11215
    ToPort 11215
    CidrIp "172.30.0.0/24"
  }

  EC2_SecurityGroupIngress(:CouchbaseGroupIngress21100to21199) {
    GroupId Ref(:CouchbaseSecurityGroup)
    IpProtocol "tcp"
    FromPort 21100
    ToPort 21199
    CidrIp "172.30.0.0/24"
  }

  EC2_SecurityGroupIngress(:CouchbaseGroupIngress22) {
    GroupId Ref(:CouchbaseSecurityGroup)
    IpProtocol "tcp"
    FromPort 22
    ToPort 22
    CidrIp "0.0.0.0/0"
  }

  EC2_SecurityGroupIngress(:CouchbaseGroupIngress8091) {
    GroupId Ref(:CouchbaseSecurityGroup)
    IpProtocol "tcp"
    FromPort 8091
    ToPort 8091
    CidrIp "0.0.0.0/0"
  }

  EC2_SecurityGroupIngress(:CouchbaseGroupIngress11210) {
    GroupId Ref(:CouchbaseSecurityGroup)
    IpProtocol "tcp"
    FromPort 11210
    ToPort 11210
    CidrIp "0.0.0.0/0"
  }

  EC2_SecurityGroupIngress(:CouchbaseGroupIngress4369) {
    GroupId Ref(:CouchbaseSecurityGroup)
    IpProtocol "tcp"
    FromPort 4369
    ToPort 4369
    CidrIp "0.0.0.0/0"
  }

  MACHINES ||= 3

  (1..MACHINES).each do |i|
    name = "machine#{i}"
    EC2_Instance(name) {
      ImageId "ami-234ecc54"
      InstanceType "t2.small"
      KeyName "default"
      Property("NetworkInterfaces",
        [
          {
            "DeviceIndex" => 0,
            "SubnetId" => Ref(:subnet),
            "GroupSet" => [Ref(:CouchbaseSecurityGroup)],
            "AssociatePublicIpAddress" => true
          }
        ]
      )
    }
  end
}
