#!/bin/bash
set -euxv

### Exec this script from K8s worker node.


## git
wget https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash
mv git-completion.bash .git-completion.bash
wget https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
mv git-prompt.sh .git-prompt.sh
cat <<'EOF' >>~/.bashrc
# git config  (add here)
. ~/.git-completion.bash
. ~/.git-prompt.sh
export GIT_PS1_SHOWDIRTYSTATE=1
export PS1='\[\033[32m\]\u@\h\[\033[00m\]:\[\033[34m\]\w\[\033[31m\]$(__git_ps1)\[\033[00m\]\$ '
EOF
git config --global user.email "iguchi.t@gmail.com"
git config --global user.name "Takashi Iguchi"


### ls-color
wget https://raw.githubusercontent.com/seebi/dircolors-solarized/master/dircolors.ansi-universal
mv dircolors.ansi-universal .dircolors
cat <<'EOF' >>~/.bashrc
# ls color config (add here)
if [ -f ~/.dircolors ]; then
    if type dircolors > /dev/null 2>&1; then
        eval $(dircolors ~/.dircolors)
    fi
fi
EOF


### fix sudo error 
sudo sh -c 'echo 127.0.1.1 $(hostname) >> /etc/hosts'


### swap off
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab


### install docker
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable"
sudo apt-get update && sudo apt-get install -y docker-ce=$(apt-cache madison docker-ce | grep 17.03 | head -1 | awk '{print $3}')


### install kubeadm
sudo apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo tee /etc/apt/sources.list.d/kubernetes.list <<EOF
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl


### enable non sudo docker command
sudo usermod -aG docker $USER


### check mac address and uuid
ip link
sudo cat /sys/class/dmi/id/product_uuid


### install nfs client for persistentvolume using NFS
sudo apt-get install -y nfs-common


### install jq for kubectl parse
sudo apt-get install -y jq


### join k8s cluster
#sudo kubeadm join xxx.xxx.xxx.xxx:xxx --token xxxxxxx --discovery-token-ca-cert-hash sha256:xxxxxx
# TODO: must replace the above line to the result of master's "sudo kubeadm token create --print-join-command" result
