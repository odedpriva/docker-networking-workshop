#!/usr/bin/env bash -e

network_name=dockermeetup
#number_of_managers=3
number_of_workers=1
leader_node=manager1
docker_image_to_use=docker:dind
init_image=odedpriva/docker-meetup:0.1.0

echo ----- creating ${network_name} network -----
docker network ls | grep ${network_name} || docker network create ${network_name}

echo ----- creating leader ${leader_node}-----
docker run -d -p 8080:8080 -p 2377 --privileged --name ${leader_node} -h ${leader_node} --net=${network_name} ${docker_image_to_use}
#
#echo ----- initiating ${number_of_managers} managers -----
#for i in `seq 2 $number_of_managers`; do
#  docker run -d -p 2377 --privileged --name manager${i} -h manager${i} --net=${network_name} ${docker_image_to_use}
#done
#docker ps -f name=manager


echo ------ initiating ${number_of_workers} workers ------
for i in `seq 1 $number_of_workers`; do
  docker run -d -p 7946  --privileged --name worker${i} -h worker${i} --net=${network_name} ${docker_image_to_use}
done
docker ps -f name=worker

echo ------ creating swarm ------
docker exec ${leader_node} docker swarm init --listen-addr 0.0.0.0:2377
manager_token=$(docker exec ${leader_node} docker swarm join-token -q manager)
worker_token=$(docker exec ${leader_node} docker swarm join-token -q worker)
leader_ip=$(docker inspect --format "{{ .NetworkSettings.Networks.${network_name}.IPAddress }}" ${leader_node})

#echo ----- connecting manages to ${leader_node}  using token ${manager_token} and ip ${leader_ip} -----
#for i in `seq 2 $number_of_managers`; do
#  docker exec manager${i} docker swarm join --token ${manager_token} ${leader_ip}:2377
#done

#echo ------ disable managers from being worker ------
#for i in `seq 1 $number_of_managers`; do
#  docker exec manager1 docker node update --availability drain manager${i}
#done

echo ------ connecting workers to swarm using token ${worker_token} and ip ${leader_ip} ------
for i in `seq 1 $number_of_workers`; do
  docker exec worker${i} docker swarm join --token ${worker_token} ${leader_ip}:2377
done

docker exec ${leader_node} docker node ls

echo ------ downloading ${init_image} image to workers ------
for i in `seq 1 $number_of_workers`; do
  docker exec -d worker${i} docker pull ${init_image}
done


: '

using tcpdump packet analyzer 
#docker run --rm --net=container:manager1 crccheck/tcpdump tcp port 2377 and dst manager2.dockerMeetup  -i any --immediate-mode -c 10

'




