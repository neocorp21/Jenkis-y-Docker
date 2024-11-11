Jenkis 


Docker


crear contenedoor jenkis

docker run -d --name jenkins  -p 8080:8080 -p 50000:50000  -v jenkins_home:/var/jenkins_home  -v /var/run/docker.sock:/var/run/docker.sock jenkins/jenkins:lts

docker exec -it --user root jenkins /bin/bash
apt-get update
apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io


