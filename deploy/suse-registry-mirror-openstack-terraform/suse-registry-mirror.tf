variable "auth_url" {}
variable "domain_name" {}
variable "region_name" {}
variable "project_name" {}
variable "user_name" {}
variable "password" {}
variable "image_name" {}
variable "internal_net" {}
variable "external_net" {}
variable "admin_size" {}
variable "sles_base" {}
variable "sles_update" {}
variable "containers_module_base" {}
variable "containers_module_update" {}
variable "https" {}
variable "dnsdomain" {}

provider "openstack" {
  domain_name = "${var.domain_name}"
  tenant_name = "${var.project_name}"
  user_name = "${var.user_name}"
  password = "${var.password}"
  auth_url = "${var.auth_url}"
  insecure = "true"
}

data "template_file" "repos" {
  template = "${file("repositories.tpl")}"

  vars {
    sles_base = "${var.sles_base}"
    sles_update = "${var.sles_update}"
    containers_module_base = "${var.containers_module_base}"
    containers_module_update = "${var.containers_module_update}"
    hostdomain = "suse-registry-mirror.${var.dnsdomain}"
    https = "${var.https}"
  }
}

resource "openstack_compute_keypair_v2" "keypair" {
  name       = "suse-registry-mirror-openstack-ssh"
  region     = "${var.region_name}"
  public_key = "${file("ssh/id_suse-registry-mirror.pub")}"
}

resource "openstack_compute_secgroup_v2" "secgroup_base" {
  name        = "suse-registry-mirror"
  region      = "${var.region_name}"
  description = "Basic security group for the suse registry mirror"

  rule {
    from_port   = -1
    to_port     = -1
    ip_protocol = "icmp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 5000 
    to_port     = 5000
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}

resource "openstack_compute_instance_v2" "suse-registry-mirror" {

  name       = "suse-registry-mirror"
  region     = "${var.region_name}"
  image_name = "${var.image_name}"

  connection {
    private_key = "${file("ssh/id_suse-registry-mirror.pub")}"
  }

  flavor_name = "${var.admin_size}"
  key_pair    = "suse-registry-mirror-openstack-ssh"

  network {
    name = "${var.internal_net}"
  }

  security_groups = [
    "${openstack_compute_secgroup_v2.secgroup_base.name}",
  ]

  user_data = "${data.template_file.repos.rendered}"
}

data "openstack_dns_zone_v2" "zone_1" {
  name = "${var.dnsdomain}."
}

resource "openstack_dns_recordset_v2" "registry-mirror-A-record" {
  zone_id = "${data.openstack_dns_zone_v2.zone_1.id}"
  name = "suse-registry-mirror.${var.dnsdomain}."
  description = "suse registry mirror A recordset"
  ttl = 5
  type = "A"
  records = ["${openstack_networking_floatingip_v2.suse-registry-mirror_ext.address}"]
  depends_on = ["openstack_compute_instance_v2.suse-registry-mirror", "openstack_compute_floatingip_associate_v2.admin_ext_ip"]
}

resource "null_resource" "suse-registry-mirror" {


  connection {
    type = "ssh"
    user = "sles"
    host = "${openstack_compute_floatingip_associate_v2.admin_ext_ip.floating_ip}"
    private_key = "${file("ssh/id_suse-registry-mirror")}"
  }

  provisioner "file" {
    source      = "suse-registry-mirror.sh"
    destination = "/tmp/suse-registry-mirror.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo -u root chmod +x /tmp/suse-registry-mirror.sh",
      "sudo -u root /tmp/suse-registry-mirror.sh",
    ]
  }
  depends_on = ["openstack_compute_instance_v2.suse-registry-mirror"]
}

resource "openstack_networking_floatingip_v2" "suse-registry-mirror_ext" {
  pool = "${var.external_net}"
}

resource "openstack_compute_floatingip_associate_v2" "admin_ext_ip" {
  floating_ip = "${openstack_networking_floatingip_v2.suse-registry-mirror_ext.address}"
  instance_id = "${openstack_compute_instance_v2.suse-registry-mirror.id}"
}


output "external_ip_admin" {
  value = "${openstack_networking_floatingip_v2.suse-registry-mirror_ext.address}"
}

output "https velum UI" {
  value = "${format("https://%s:5000" ,"suse-registry-mirror.${var.dnsdomain}")}"
}

output "http velum UI" {
  value = "${format("http://%s:5000" ,"suse-registry-mirror.${var.dnsdomain}")}"
}
