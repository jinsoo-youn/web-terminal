FROM alpine:3.16.2

USER root

ENV ARCH="x86_64"
RUN echo > /etc/apk/repositories && echo -e "https://dl-cdn.alpinelinux.org/alpine/latest-stable/main\nhttps://dl-cdn.alpinelinux.org/alpine/latest-stable/community" >> /etc/apk/repositories
RUN apk update && apk upgrade && apk add --update --no-cache bash bash-completion curl git wget openssl iputils busybox-extras vim && sed -i "s/nobody:\//nobody:\/nonexistent/g" /etc/passwd

# get kubectl
RUN export KUBE_VERSION="v1.24.3" && export ARCH="amd64" && curl -sLf https://storage.googleapis.com/kubernetes-release/release/${KUBE_VERSION}/bin/linux/${ARCH}/kubectl > /usr/bin/kubectl && chmod +x /usr/bin/kubectl
# get k9s
RUN cd /tmp/ && wget https://github.com/derailed/k9s/releases/download/v0.25.21/k9s_Linux_${ARCH}.tar.gz && tar -xvf k9s_Linux_${ARCH}.tar.gz && chmod +x k9s && mv k9s /usr/bin/k9s && chmod +x /usr/bin/k9s
# get kubens
RUN KUBECTX_VERSION=v0.9.4 && wget https://github.com/ahmetb/kubectx/releases/download/${KUBECTX_VERSION}/kubens_${KUBECTX_VERSION}_linux_${ARCH}.tar.gz && tar -xvf kubens_${KUBECTX_VERSION}_linux_${ARCH}.tar.gz && chmod +x kubens && mv kubens /usr/bin
# get helm
RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
# get ttyd for web terminal
RUN export ARCH="x86_64" && wget https://github.com/tsl0922/ttyd/releases/download/1.7.1/ttyd.${ARCH} && chmod +x ttyd.${ARCH} && mv ttyd.${ARCH} /usr/bin/ttyd 

# COPY start.sh 

EXPOSE 7681

RUN mkdir -p /opt/webterminal
COPY start.sh /opt/webterminal
RUN chmod +x /opt/webterminal/start.sh

RUN mkdir -p /var/run/secrets/kubernetes.io/serviceaccount
COPY ca.crt  /var/run/secrets/kubernetes.io/serviceaccount
COPY token /var/run/secrets/kubernetes.io/serviceaccount
ENV KUBERNETES_SERVICE_HOST="https://192.168.9.189"
ENV KUBERNETES_SERVICE_PORT="6443"

#CMD ["ttyd","bash"]
CMD ["sh","/opt/webterminal/start.sh"]
