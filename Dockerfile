FROM alpine:3.16.2

USER root

RUN apk update \
 && apk upgrade \
 && apk add --update --no-cache bash bash-completion curl git wget openssl iputils busybox-extras vim
    
RUN sed -i "s/nobody:\//nobody:\/nonexistent/g" /etc/passwd

# get kubectl
RUN export KUBE_VERSION="v1.24.3" \
 && export ARCH="$(uname -m)" && if [[ ${ARCH} == "x86_64" ]]; then export ARCH="amd64"; elif [[ ${ARCH} == "aarch64" ]]; then export ARCH="arm64"; fi \
 && curl -sLf https://storage.googleapis.com/kubernetes-release/release/${KUBE_VERSION}/bin/linux/${ARCH}/kubectl > /usr/bin/kubectl \
 && chmod +x /usr/bin/kubectl
# get k9s
RUN export ARCH="$(uname -m)" && if [[ ${ARCH} == "x86_64" ]]; then export ARCH="x86_64"; elif [[ ${ARCH} == "aarch64" ]]; then export ARCH="arm64"; fi \
 && cd /tmp/ \
 && export K9S_VERSION="v0.26.3" \
 && wget https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_${ARCH}.tar.gz \
 && tar -xvf k9s_Linux_${ARCH}.tar.gz \
 && chmod +x k9s && mv k9s /usr/bin/k9s \
# get kubens & kubectx
 && export KUBECTX_VERSION="v0.9.4" \
 && wget https://github.com/ahmetb/kubectx/releases/download/${KUBECTX_VERSION}/kubens_${KUBECTX_VERSION}_linux_${ARCH}.tar.gz \
 && tar -xvf kubens_${KUBECTX_VERSION}_linux_${ARCH}.tar.gz \
 && chmod +x kubens && mv kubens /usr/bin \
 && wget https://github.com/ahmetb/kubectx/releases/download/${KUBECTX_VERSION}/kubectx_${KUBECTX_VERSION}_linux_${ARCH}.tar.gz \
 && tar -xvf kubectx_${KUBECTX_VERSION}_linux_${ARCH}.tar.gz \
 && chmod +x kubectx && mv kubectx /usr/bin 
# get helm
RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash \
 && mkdir -p /etc/bash_completion.d \
 && helm completion bash > /etc/bash_completion.d/helm
# get ttyd for web terminal
RUN export TTYD_VERSION="1.7.1" \
 && export ARCH="$(uname -m)" \
 && cd /tmp/ \
 && wget https://github.com/tsl0922/ttyd/releases/download/${TTYD_VERSION}/ttyd.${ARCH} \
 && chmod +x ttyd.${ARCH} && mv ttyd.${ARCH} /usr/bin/ttyd 

# COPY start.sh 
RUN mkdir -p /opt/webterminal
COPY start.sh /opt/webterminal
RUN chmod +x /opt/webterminal/start.sh

# expose 7681 port for ttyd (webterminal server)
EXPOSE 7681
ENTRYPOINT ["sh","/opt/webterminal/start.sh"]
