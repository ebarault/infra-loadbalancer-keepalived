# install aws cli

```sh
curl -O https://bootstrap.pypa.io/get-pip.py
sudo python get-pip.py
sudo pip install awscli
```

# create and configure the relevant role for the servers so they are able to use the AWS CLI to switch the elastic IPs

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "ec2:AssignPrivateIpAddresses",
                "ec2:AssociateAddress",
                "ec2:DescribeInstances"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
}
```

# configure AWS CLI

> see http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html
first create a user with the right of authorizations

```sh
aws configure
```

# install keepalived

```sh
sudo apt-get update
sudo apt-get install build-essential libssl-dev
wget http://www.keepalived.org/software/keepalived-1.2.24.tar.gz
tar xzvf keepalived*
cd keepalived*
./configure
make
sudo make install
cp ./etc/init/keepalived.conf /etc/init/keepalived.conf
cp keepalived.lb01.conf /etc/keepalived/keepalived.conf		# on master. use .lb02 on slave
cp master.sh /etc/keepalived/master.sh
cp backup.sh /etc/keepalived/backup.sh
chmod 700 /etc/keepalived/master.sh
```

# enable instance to use non bound interfaces

> this tell the kernel we'll be using IP's that are not defined in the interfaces file

```sh
sudo vim /etc/sysctl.conf
net.ipv4.ip_nonlocal_bind=1
```

> this tells the server to activate what we put in the sysctl.conf file without rebooting the server

```sh
sysctl -p
```
