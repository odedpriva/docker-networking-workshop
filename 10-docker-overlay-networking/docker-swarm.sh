#!/usr/bin/env bash -e

prefix=nethandson
network_name=${prefix}
manager_node=${prefix}_manager
server_node=${prefix}_server
proxy_node=${prefix}_proxy
docker_image_to_use=docker:dind
init_image=odedpriva/docker-meetup:0.1.0
swarm_network=mynet

if [[ $1 == 'cleanup' ]]; then
    printf '\n\e[1;34m%-6s\e[m\n' 'deleting workshop containers'
    docker rm -f $(docker ps -q -f name=${prefix}) 2> /dev/null
    printf '\n\e[1;34m%-6s\e[m\n' 'deleting workshop networks'
    docker network rm ${prefix} 2> /dev/null
    exit
fi


printf "\n\e[1;34m%-6s\e[m\n" "creating ${network_name} network"
docker network ls | grep ${network_name} || docker network create ${network_name}

printf "\n\e[1;34m%-6s\e[m\n" "creating ${manager_node}"
docker run -d -p 8000:8000 -p 2377 --privileged --name ${manager_node} -h ${manager_node} --net=${network_name} ${docker_image_to_use}

printf "\n\e[1;34m%-6s\e[m\n" 'creating nodes as workers'
docker run -d -p 7946  --privileged -v ${PWD}:/tmp --name ${server_node} -h ${server_node} --net=${network_name} ${docker_image_to_use}
docker run -d -p 7946  --privileged -v ${PWD}:/tmp --name ${proxy_node} -h ${proxy_node} --net=${network_name} ${docker_image_to_use}

printf "\n\e[1;34m%-6s\e[m\n" 'loading images to workers'
docker exec ${server_node} docker load -i /tmp/docker-images/proxy.tar
docker exec ${server_node} docker load -i /tmp/docker-images/busybox.tar
docker exec ${server_node} docker load -i /tmp/docker-images/tcpdump.tar
docker exec ${proxy_node} docker load -i /tmp/docker-images/proxy.tar
docker exec ${proxy_node} docker load -i /tmp/docker-images/busybox.tar
docker exec ${proxy_node} docker load -i /tmp/docker-images/tcpdump.tar

printf "\n\e[1;34m%-6s\e[m\n" 'creating swarm'
docker exec ${manager_node} docker swarm init --listen-addr 0.0.0.0:2377
manager_token=$(docker exec ${manager_node} docker swarm join-token -q manager)
workers_token=$(docker exec ${manager_node} docker swarm join-token -q worker)
manager_ip=$(docker inspect --format "{{ .NetworkSettings.Networks.${network_name}.IPAddress }}" ${manager_node})

printf "\n\e[1;34m%-6s\e[m\n" 'connecting nodes to swarm'
docker exec ${server_node} docker swarm join --token ${workers_token} ${manager_ip}:2377
docker exec ${proxy_node} docker swarm join --token ${workers_token} ${manager_ip}:2377

printf "\n\e[1;34m%-6s\e[m\n" 'draining manager'
docker exec ${manager_node} docker node update --availability drain ${manager_node}

printf "\n\e[1;34m%-6s\e[m\n" 'assigning nodes a constrain'
docker exec ${manager_node} docker node update --label-add type=proxy ${proxy_node}
docker exec ${manager_node} docker node update --label-add type=server ${server_node}

if [[ $1 == "full" ]]; then
    printf "\n\e[1;34m%-6s\e[m\n" "creating ${swarm_network} overlay network"
    docker exec ${manager_node} docker network create ${swarm_network} -d overlay
    printf "\n\e[1;34m%-6s\e[m\n" 'creating server service'
    docker exec ${manager_node} docker service create --constraint 'node.labels.type == server' --replicas 2 --name server --network ${swarm_network} busybox busybox httpd -f -p 8000
    printf "\n\e[1;34m%-6s\e[m\n" 'creating proxy service'
    docker exec ${manager_node} docker service create --constraint 'node.labels.type == proxy' --replicas 2 --name proxy --network ${swarm_network} -p 8000:8000 odedpriva/proxy

    printf "\n\e[1;34m%-6s\e[m\n" 'server list'
    docker exec ${manager_node} docker service ps server 2> /dev/null
    printf "\n\e[1;34m%-6s\e[m\n" 'proxy list'
    docker exec ${manager_node} docker service ps proxy 2> /dev/null
fi


printf "\n\e[1;34m%-6s\e[m\n" "setting aliases"
printf "%s\n" "
alias manager='docker exec ${manager_node}'
alias proxy='docker exec ${proxy_node}'
alias server='docker exec ${server_node}'
"

printf "\n\e[1;34m%-6s\e[m\n" '
curl localhost:8000/etc/hostname
'


: '

using tcpdump packet analyzer 
#docker run --rm --net=container:manager1 crccheck/tcpdump tcp port 2377 and dst manager2.dockerMeetup  -i any --immediate-mode -c 10

'




