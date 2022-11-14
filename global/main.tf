terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
provider "aws" {
  profile = "default"
  region  = var.region
}
module "tomcat_vpc" {
  source   = "../modules/services/network/vpc"
  vpc_cidr = var.vpc_cidr
  vpc_name = var.vpc_name
}
module "tomcat_subnet" {
  source            = "../modules/services/network/subnet"
  count             = length(var.subnet_cidr)
  vpc_id            = module.tomcat_vpc.vcp_id
  subnet_cidr       = element(var.subnet_cidr, count.index)
  availability_zone = element(var.availability_zone, count.index % 2)
  subnet_name       = "fithealth_${count.index + 1}"
}
module "tomcat_ig" {
  source     = "../modules/services/network/gateways/ig"
  vpc_id     = module.tomcat_vpc.vcp_id
  subnet_id  = [module.tomcat_subnet[4].subnet_id, module.tomcat_subnet[5].subnet_id]
  ig_name    = var.ig_cofig.ig_name
  ig_rt_name = var.ig_cofig.ig_rt_name

}
module "tomcat_natgateway" {
  source           = "../modules/services/network/gateways/nat"
  vpc_id           = module.tomcat_vpc.vcp_id
  subnet_id        = [module.tomcat_subnet[0].subnet_id, module.tomcat_subnet[1].subnet_id]
  public_subnet_id = module.tomcat_subnet[4].subnet_id
  nat_gateway_name = "nat"
  depends_on = [
    module.tomcat_ig
  ]
 
}
module "keypair" {
  source     = "../modules/services/compute/keypair"
  public_key = var.keypair_config.public_key
  key_name   = var.keypair_config.key_name

}
module "tomcat_ec2" {
  count                       = 2
  source                      = "../modules/services/compute/ec2"
  subnet_id                   = module.tomcat_subnet[count.index].subnet_id
  ami                         = var.ec2_config.ami
  vpc_id                      = module.tomcat_vpc.vcp_id
  sg_cidr_block               = [module.tomcat_vpc.vpc_cidr]
  instance_type               = var.ec2_config.instance_type
  associate_public_ip_address = true
  key_name                    = var.keypair_config.key_name
  instance_name               = "${var.ec2_config.instance_name}_${count.index + 1}"
  depends_on = [
    module.tomcat_natgateway,
    module.application_db
  ]
}
module "jumpbox_ec2" {
  source                      = "../modules/services/compute/ec2"
  vpc_id                      = module.tomcat_vpc.vcp_id
  sg_cidr_block               = [module.tomcat_vpc.vpc_cidr]
  subnet_id                   = module.tomcat_subnet[5].subnet_id
  ami                         = var.ec2_config.ami
  instance_type               = var.ec2_config.instance_type
  associate_public_ip_address = true
  key_name                    = var.keypair_config.key_name
  instance_name               = "jumpbox_ec2"
  depends_on = [
    module.tomcat_ec2,
    module.application_db
  ]
}
module "application_db" {
  source                 = "../modules/services/database"
  vpc_id                 = module.tomcat_vpc.vcp_id
  db_cidr                = [module.tomcat_vpc.vpc_cidr]
  engine                 = var.application_db.engine
  engine_version         = var.application_db.engine_version
  instance_class         = var.application_db.instance_class
  db_name                = var.application_db.db_name
  username               = var.application_db.username
  password               = var.application_db.password
  allocated_storage      = var.application_db.allocated_storage
  db_subnet_group_name = var.application_db.db_subnet_group_name
  subnet_id              = [module.tomcat_subnet[2].subnet_id, module.tomcat_subnet[3].subnet_id]
  skip_final_snapshot    = var.application_db.skip_final_snapshot
  parameter_group_name   = var.application_db.parameter_group_name

}
module "application_lbr" {
  source      = "../modules/services/compute/elb"
  vpc_id      = module.tomcat_vpc.vcp_id
  subnet_id   = [module.tomcat_subnet[4].subnet_id, module.tomcat_subnet[5].subnet_id]
  tg_name     = var.lbr_config.tg_name
  instance1   = module.tomcat_ec2[0].instance_id
  instance2   = module.tomcat_ec2[1].instance_id
  lbr_name    = var.lbr_config.lbr_name
  lbr_sg_name = var.lbr_config.lbr_sg_name
  depends_on = [
    resource.null_resource.config_file_copy
  ]
}
resource "null_resource" "config_software" {

  depends_on = [
    module.jumpbox_ec2
  ]
  
}
resource "null_resource" "config_file_copy" {
    provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = module.jumpbox_ec2.ec2_public_ip
      user        = "ubuntu"
      private_key = file("~/.ssh/terraform")
    }
    inline = [
      "sudo rm -r /tmp/fithealth2",
      "sudo apt update -y",
      "sudo apt install mysql-client -y",
      "sudo apt install ansible -y",
      "sudo apt install openjdk-11-jdk -y",
      "sudo apt install maven -y",
      "cd /tmp/",
      "git clone https://github.com/nazeerbs/fithealth2.git",
    ]
  }
  provisioner "file" {
    connection {
      type        = "ssh"
      host        = module.jumpbox_ec2.ec2_public_ip
      user        = "ubuntu"
      private_key = file("../sshkeys/terraform")
    }
    source      = "../sshkeys/terraform"
    destination = "/home/ubuntu/.ssh/terraform"
  }
  provisioner "file" {
    connection {
      type        = "ssh"
      host        = module.jumpbox_ec2.ec2_public_ip
      user        = "ubuntu"
      private_key = file("../sshkeys/terraform")
    }
    source      = "../ansible"
    destination = "/tmp/fithealth2/"
  }
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = module.jumpbox_ec2.ec2_public_ip
      user        = "ubuntu"
      private_key = file("../sshkeys/terraform")
    }
    inline = [
      "sudo chmod 600 /home/ubuntu/.ssh/terraform",
      "sed -i 's/connectstring/${module.application_db.db_endpoint}/g' /tmp/fithealth2/src/main/resources/db.properties && mvn -f /tmp/fithealth2/pom.xml clean verify",
      "printf '%s\n%s' ${module.tomcat_ec2[0].ec2_private_ip } ${module.tomcat_ec2[1].ec2_private_ip} > /tmp/fithealthhosts",
      "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook --private-key ~/.ssh/terraform -i /tmp/fithealthhosts /tmp/fithealth2/ansible/tomcat-playbook.yml",
      "mysql -h ${module.application_db.db_address} -u${var.application_db.username} -p${var.application_db.password} < /tmp/fithealth2/src/main/db/db-schema.sql"

    ]

  }
  depends_on = [
    resource.null_resource.config_software
  ]

}

