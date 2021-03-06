#!/bin/bash

echo "Destroying Consul containers..."
docker -H 10.0.7.11:2375 rm -f consul1
docker -H 10.0.7.12:2375 rm -f consul2
docker -H 10.0.7.13:2375 rm -f consul3

echo "Destroying Swarm manager..."
docker -H 10.0.7.11:2375 rm -f swarm_manager

# Run the first and second Swarm nodes
echo "Destroying Swarm node #1..."
docker -H 10.0.7.12:2375 rm -f swarm_node1
echo "Destroying Swarm node #2..."
docker -H 10.0.7.13:2375 rm -f swarm_node2
