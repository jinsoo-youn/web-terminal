#!/bin/bash

echo "Environment variables:"
env

echo "export TERM=xterm-256color" >> /root/.bashrc
echo "source /usr/share/bash-completion/bash_completion" >> /root/.bashrc
echo 'source <(kubectl completion bash)' >> /root/.bashrc
echo 'alias k=kubectl' >> /root/.bashrc
echo 'complete -o default -F __start_kubectl k' >> /root/.bashrc

echo `kubectl config set-credentials webkubectl-user --token=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)` > /dev/null 2>&1
echo `kubectl config set-cluster kubernetes --server=$(echo ${KUBERNETES_SERVICE_HOST}):$(echo ${KUBERNETES_SERVICE_PORT}) --certificate-authority=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt` > /dev/null 2>&1
echo `kubectl config set-context kubernetes --cluster=kubernetes --user=webkubectl-user` > /dev/null 2>&1
echo `kubectl config use-context kubernetes` > /dev/null 2>&1

# helm completion bash 
# source <(helm completion bash)

ttyd bash
