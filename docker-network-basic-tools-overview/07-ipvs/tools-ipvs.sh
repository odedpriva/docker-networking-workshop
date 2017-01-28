#!/usr/bin/env bash -e

lab_name=ipvs
network_name=${lab_name}
network_director_name=${lab_name}1
init_image=server
ipvs_director_image=ipvs
port=8000

cleanup(){
    printf '\n\e[1;34m%-6s\e[m\n' 'deleting workshop containers'
    docker rm -f $(docker ps -q -a -f name=${lab_name}) 2> /dev/null
    printf '\n\e[1;34m%-6s\e[m\n' 'deleting workshop networks'
    docker network rm $(docker network ls -f name=${lab_name} -q) 2> /dev/null
    exit 0
}

create(){
    printf "\n\e[1;34m%-6s\e[m\n" "creating ${network_name} network"
    docker network ls | grep -w ${network_director_name} || docker network create ${network_director_name} --subnet=1.2.3.4/16 --ip-range=1.2.3.4/24 
    docker network ls | grep -w ${network_name} || docker network create ${network_name} --subnet=10.0.0.0/16 --ip-range=10.0.0.0/24 --gateway 10.0.0.4

    printf "\n\e[1;34m%-6s\e[m\n" 'creating servers'
    docker run -d --ip 1.2.3.4 -h director --name ${lab_name}_director --privileged -p ${port}:${port} --network ${network_director_name} ${ipvs_director_image} top
    docker run -d --ip 10.0.0.2 -h ${lab_name}_1 --name ${lab_name}_1 --privileged -p ${port} --network ${network_name} ${init_image}
    docker run -d --ip 10.0.0.3 -h ${lab_name}_2 --name ${lab_name}_2 --privileged -p ${port} --network ${network_name} ${init_image}
    docker network connect ${network_name} ${lab_name}_director 
}

data(){

printf "\n\e[1;34m%-6s\e[m\n" "no data"
exit 0
}


usage() {
  printf "\e[1;34m%-6s\e[m\n" "

    $(basename $0) [-h] [-c] [-s] [-d]

    -c: cleanup all containers and networking
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
      s)
        printf "\e[1;34m%-6s\e[m\n" "creating "
        create
        ;;
      h)
        usage 0
        ;;
      \?)
        printf "\n\e[1;31m%s\e[m" 'invalid usage'
        usage 1
        ;;
      :)
        usage 1
        ;;
    esac
  done

}
if [[ $# -eq 0 ]] ; then
    printf "\n\e[1;31m%s\e[m" 'invalid usage'
    usage 1
fi

main "$@"


