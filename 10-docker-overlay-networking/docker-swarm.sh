#!/usr/bin/env bash -e

prefix=nethandson
network_name=${prefix}
manager_node=${prefix}_manager
server_node=${prefix}_server
proxy_node=${prefix}_proxy
swarm_network=mynet
docker_image_to_use=docker:dind
init_image=odedpriva/docker-meetup:0.1.0
port=8000



cleanup(){
    printf '\n\e[1;34m%-6s\e[m\n' 'deleting workshop containers'
    docker rm -f $(docker ps -q -f name=${prefix}) 2> /dev/null
    printf '\n\e[1;34m%-6s\e[m\n' 'deleting workshop networks'
    docker network rm ${prefix} 2> /dev/null
    exit 0
}


create_swarm(){
    printf "\n\e[1;34m%-6s\e[m\n" "creating ${network_name} network"
    docker network ls | grep ${network_name} || docker network create ${network_name}

    printf "\n\e[1;34m%-6s\e[m\n" "creating ${manager_node}"
    docker run -d -p ${port}:${port} -p 2377 --privileged --name ${manager_node} -h ${manager_node} --net=${network_name} ${docker_image_to_use}

    printf "\n\e[1;34m%-6s\e[m\n" 'creating nodes as workers'
    docker run -d -p 7946  --privileged -v ${PWD}:/tmp --name ${server_node} -h ${server_node} --net=${network_name} ${docker_image_to_use}
    docker run -d -p 7946  --privileged -v ${PWD}:/tmp --name ${proxy_node} -h ${proxy_node} --net=${network_name} ${docker_image_to_use}

    printf "\n\e[1;34m%-6s\e[m\n" 'loading images to server worker'
    docker exec ${server_node} docker load -i /tmp/docker-images/proxy.tar
    docker exec ${server_node} docker load -i /tmp/docker-images/busybox.tar
    docker exec ${server_node} docker load -i /tmp/docker-images/tcpdump.tar
    printf "\n\e[1;34m%-6s\e[m\n" 'loading images to proxy server'
    docker exec ${proxy_node} docker load -i /tmp/docker-images/proxy.tar
    docker exec ${proxy_node} docker load -i /tmp/docker-images/busybox.tar
    docker exec ${proxy_node} docker load -i /tmp/docker-images/tcpdump.tar

    printf "\n\e[1;34m%-6s\e[m\n" 'copying nsenter to workers'
    docker cp bin/nsenter ${server_node}:/bin
    docker exec ${server_node} chmod +x /bin/nsenter
    docker cp bin/nsenter ${proxy_node}:/bin
    docker exec ${proxy_node} chmod +x /bin/nsenter
    docker cp bin/nsenter ${manager_node}:/bin
    docker exec ${manager_node} chmod +x /bin/nsenter

    printf "\n\e[1;34m%-6s\e[m\n" 'installing ipvsadm and tcpdump'
    docker exec ${proxy_node} sh -c "apk add ipvsadm tcpdump --update-cache --repository http://dl-4.alpinelinux.org/alpine/edge/main/ --allow-untrusted && rm -rf /var/cache/apk/*"
    docker exec ${server_node} sh -c "apk add ipvsadm tcpdump --update-cache --repository http://dl-4.alpinelinux.org/alpine/edge/main/ --allow-untrusted && rm -rf /var/cache/apk/*"
    docker exec ${manager_node} sh -c "apk add ipvsadm tcpdump --update-cache --repository http://dl-4.alpinelinux.org/alpine/edge/main/ --allow-untrusted && rm -rf /var/cache/apk/*"

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
}

create_services(){

#if [[ $1 == "full" ]]; then
    printf "\n\e[1;34m%-6s\e[m\n" "creating ${swarm_network} overlay network"
    docker exec ${manager_node} docker network create ${swarm_network} -d overlay
    printf "\n\e[1;34m%-6s\e[m\n" 'creating server service'
    docker exec ${manager_node} docker service create --constraint 'node.labels.type == server' --replicas 2 --name server --network ${swarm_network} busybox busybox httpd -f -p ${port}
    printf "\n\e[1;34m%-6s\e[m\n" 'creating proxy service'
    docker exec ${manager_node} docker service create --constraint 'node.labels.type == proxy' --replicas 2 --name proxy --network ${swarm_network} -p ${port}:${port} proxy

    printf "\n\e[1;34m%-6s\e[m\n" 'server list'
    docker exec ${manager_node} docker service ps server 2> /dev/null
    printf "\n\e[1;34m%-6s\e[m\n" 'proxy list'
    docker exec ${manager_node} docker service ps proxy 2> /dev/null
#fi

}

data(){

printf "\n\e[1;34m%-6s\e[m\n" "
use the aliases:
alias manager='docker exec ${manager_node}'
alias proxy='docker exec ${proxy_node}'
alias server='docker exec ${server_node}'
"

printf "\n\e[1;34m%-6s\e[m\n" "
service is exported on port ${port}, run this to get a response
curl localhost:${port}/etc/hostname
"
exit 0
}


usage() {
  printf "\e[1;34m%-6s\e[m\n" "

    $(basename $0) [-h] [-c] [-w] [-s] [-d]

    -c: cleanup all containers and networking
    -w: create swarm
    -s: create services
    -d: print data and tips
    -h: print this help
"
  exit $1
}

main() {
  while getopts ":cdwsh" opt; do
    case $opt in
      c)
        printf "\n\e[1;34m%-6s\e[m\n" 'cleaning up stack'
        cleanup
        ;;
      d)
        data
        ;;
      w)
        printf "\e[1;34m%-6s\e[m\n" "create swarm"
        create_swarm
        ;;
      s)
        printf "\e[1;34m%-6s\e[m\n" "create services"
        create_services
        ;;
      h)
        usage 0
        ;;
      \?)
        printf "\n\e[1;34m%-6s\e[m\n" 'invalid usage'
        usage 1
        ;;
      :)
        usage 1
        ;;
    esac
  done

}

main "$@"


