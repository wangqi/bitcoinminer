bitcoinminer
============

It is a vagrant project used to setup a Amazon EC2 cg1.4xlarge instance to mine bitcoin.
Someone said it makes no economic sense. But I don't believe it. Let's try.
According to Amazon, there is a instance type called '[cg1.4xlarge](http://aws.amazon.com/cn/ec2/instance-types/)'
which has 2 * Intel Xeon X5570 and 2 * NVIDIA Tesla M2050 GPU. It will cost you $2.1 per hour. Really expensive, right?
However one bitcoin is worth $948.26. If we can mine 0.053 bitcoin per day, we can earn money from it. 

**So just do it!**

# Installation
- First you have to register an AWS account.
- Select EC2 and then select the 'N.Virginia' region (Only two regions support the cg1.4xlarge now)
- Create a keypair and download the private key
- Create a security group.
- Write down your account's `access_id`, `access_key`
- Clone this git repository. Edit the 'Vagrantfile'.

```
Vagrant.require_plugin "vagrant-aws"
  config.vm.provider :aws do |aws, override|
    aws.access_key_id = "<access_id>"
    aws.secret_access_key = "<access_key>"
    aws.keypair_name = "keypair"
    aws.instance_type = "cg1.4xlarge"
    # Amazon Linux AMI (HVM GPU / 64-bit)
    aws.ami = "ami-7f5d7016"
    aws.region = "us-east-1"
    aws.security_groups = ["security-group"]
    aws.tags = {
      'Name' => 'BitcoinMiner',
    }
    aws.user_data = File.read("cloud_init.txt")
    override.ssh.username = "ec2-user"
    override.ssh.private_key_path = "~/keys/keypair.pem"
  end
 ```

- Run the 'vagrant up' command in this repository directory.
  If everything is OK, you can see a new instance has been setup for you now.

  ![revolunet logo](http://www.revolunet.com/static/parisjs8/img/logo-revolunet-carre.jpg "revolunet logo")

  And required programs are already installed for you by vagrant script.

- Run the 'vagrant ssh' command to login.
  Change the 'mine.sh' script accourding to your information. You have to register a pool account at 'stratum.bitcoin.cz'

- Run the 'mine.sh'. It will start to mine bitcoin by using both CPUs and GPUs.

# Am I rich now?
The cg1.4xlarge can mine bitcoin at the following speed ( Only test for 2 hours because I am really poor )

![revolunet logo](http://www.revolunet.com/static/parisjs8/img/logo-revolunet-carre.jpg "revolunet logo")

And I got the following bitcoin :

![revolunet logo](http://www.revolunet.com/static/parisjs8/img/logo-revolunet-carre.jpg "revolunet logo")

The **0.00000024 BTC** is about **$0.000228**. But the cost for me is **$4.2**. My heart is broken.

Anyway, The highest GPU instance in AWS can only generate 95MHash/s. However a dedicated miner hardware can
generate a lot higher MHash/s. See [comparision table](https://en.bitcoin.it/wiki/Mining_hardware_comparison)

If I am not wrong, that 95MHash/s can bring $0.000114/Hour, the EC2 should generate 1,750,000MHash/s to gain profit.

# Third Party Tools
- [Vagrant](http://www.vagrantup.com): A configurable lightweight, reproducible, and portable development environments.
- [Vagrant AWS Plugin](https://github.com/mitchellh/vagrant-aws): AWS provider for Vagrant.
- [CPUMiner](https://github.com/jgarzik/cpuminer): The miner which uses CPU to mine bitcoin.
- [poclbm](https://github.com/m0mchil/poclbm): The miner which uses GPU to mine bitcoin.