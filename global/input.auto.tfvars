region            = "ap-south-1"
vpc_cidr          = "10.0.0.0/16"
vpc_name          = "fithealth_vpc"
subnet_cidr       = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
availability_zone = ["ap-south-1a", "ap-south-1b"]
ig_cofig = {
  ig_name = "tomcat_ig"
  ig_rt_name = "tomcat_ig_rt"
}
keypair_config = {
  key_name   = "fithealthkp"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCgYcExMhY/fI0Rq/QcYRNMYWYTY1uVIczDpsd3TAzFpDjamRgO05ZspN6sgzvxTR4ckSwoKAvQrkexn97MxmlNYdnQjirEv+aBvXdyqxQzU2gr5N8bXWq3sQgl6+8aADoDPIsdGV5+b1yLxttsovGJZJ7aLjdKf4oGMxDf6p4LHkRvUacH/oBXz+vTgB1mIe/mY4OyQbeyaYMue3TeAKGhrjC+FxPXrCGYN/QnrFclpmttZX5Zphz6MsNtZq584SMCDTuP42jjEpKjyzLosObb389+4f+L9ARR1kRe4zh87NbNl09AifPXDMG+eHldWZNhx/3RRxsfTJ7Q9pYcUVwtwwrC2VFcxTVNlH0ugtWolw7UJmSDsEdmyzOG6d3M8YKp83Mp4ocMgi38af7FNjJUEKVP2HtIq4SDu8p1oX+b5CgFPf0IWESGL+F6kivoxlq43xztRMLoRtMqxmN2GE/SRhdehIP8Bpa0lVP19K4rpoMguwBneeVNIVU85PCmL5k= nazee@BASHA"
}
ec2_config = {
  instance_type = "t2.micro"
  ami           = "ami-068257025f72f470d"
  instance_name = "fithealth_ec2"
}
application_db = {
  allocated_storage = "10"
  db_name = "fithealthdb"
  db_subnet_group_name = "fithealth_db_subnetgroup"
  engine = "mysql"
  engine_version = "5.7"
  instance_class = "db.t2.micro"
  parameter_group_name = "default.mysql5.7"
  username = "fithealth"
  password = "welcome1"
  skip_final_snapshot = true
}
lbr_config = {
  lbr_name = "fithealthlbr"
  lbr_sg_name = "fithealth_lbr_sg"
  tg_name = "fithealthtg"
}