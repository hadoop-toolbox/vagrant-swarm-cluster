# Vagrant Swarm cluster

Run a Swarm cluster locally using Vagrant.

This will create and setup 4 Vagrant machines in a private network (10.0.7.0/24):

* Consul: 10.0.7.10
* Swarm manager: 10.0.7.11
* Swarm node 1: 10.0.7.12
* Swarm node 2: 10.0.7.13

# Requirements

Install [Vagrant][vagranthome] and [Docker][dockerhome] on your machine.

Ensure you have a valid [Vagrant provider][vagrantprovider] installed.

# Setup

## Boot Vagrant machines

The first thing you must do is to start the Vagrant machines using your favorite provider:

```
$ git clone https://github.com/deviantony/vagrant-swarm-cluster.git
$ cd vagrant-swarm-cluster
$ vagrant up --provider virtualbox
```

Supported providers:

* virtualbox
* vmware_desktop
* parallels

## Bootstrap script

If you're on Unix, you can execute the `start_cluster.sh` script to bootstrap the Swarm cluster:

```shell
$ chmod +x start_cluster.sh
$ ./start_cluster.sh
```

## Commands

Or execute the following commands to start the cluster.

Start the Consul container:

```shell
$ docker -H 10.0.7.10:2375 run -d --restart always -p 8500:8500 --name consul progrium/consul -server -bootstrap
```

Start a Swarm manager node:

```shell
$ docker -H 10.0.7.11:2375 run -d --restart always -p 4000:4000 --name swarm_manager swarm manage -H :4000 --replication --advertise 10.0.7.11:2375
$ consul://10.0.7.10:8500
```

Start two Swarm nodes:

```shell
$ docker -H 10.0.7.12:2375 run -d --restart always --name swarm_node1 swarm join --advertise 10.0.7.12:2375 consul://10.0.7.10:8500
$ docker -H 10.0.7.13:2375 run -d --restart always --name swarm_node2 swarm join --advertise 10.0.7.13:2375 consul://10.0.7.10:8500
```

Check Swarm cluster status:

```shell
$ docker -H 10.0.7.11:4000 info
```

# Go further

Setup a NFS file share between your Swarm nodes to host your Docker volumes.

We'll use a the [Nginx image][nginximage] to start multiple Nginx containers inside the Swarm cluster.

These containers will be load-balanced across our Swarn nodes but will share the same data volume.

## Networking

Create an overlay network in your Swarm cluster to allow communication between your containers in the cluster:

```shell
$ docker -H 10.0.7.11:4000 network create cluster_network
```

## Volume

Create a shared volume:

```shell
$ docker -H 10.0.7.11:4000 volume create --name nginx-vol
```

## Nginx containers and shared data

Start a new Nginx container in the Swarm cluster:
```shell
$ docker -H 10.0.7.11:4000 run -d -p 80:80 --net my_shared_network -v shared-vol:/usr/share/nginx/html --name nginx1 nginx
```

At this point, if you access `10.0.7.12:80`, it should display Nginx welcome page.

Copy the `index.html` file to be served by the Nginx container.
```shell
$ docker -H 10.0.7.11:4000 cp index.html nginx1:/usr/share/nginx/html/
```

If you now access `10.0.7.12:80`, it should display the content of the `index.html` file.

Start another Nginx container:
```shell
$ docker -H 10.0.7.11:4000 run -d -p 80:80 --net my_shared_network -v shared-vol:/usr/share/nginx/html --name nginx2 nginx
```

Now, access our second Swarm node `10.0.7.13:80`, you should see the same page than the one displayed on the first node.

[vagranthome]: https://www.vagrantup.com/docs/installation/  "Vagrant installation"
[vagrantprovider]: https://www.vagrantup.com/docs/providers/ "Vagrant providers"
[dockerhome]: https://docs.docker.com/engine/installation/  "Docker installation"
[nginximage]: https://hub.docker.com/_/nginx/ "Nginx Docker image"
