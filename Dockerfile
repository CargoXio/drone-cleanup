FROM alpine:latest

ENV HOME=/kubectl

RUN set -x && \
    apk add --no-cache curl ca-certificates && \
    mkdir -p $HOME && \
    curl -qsfL https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl && \
    adduser kubectl -Du 1978 -h $HOME
ADD drone-cleanup.sh $HOME
RUN chmod +x /kubectl/drone-cleanup.sh
WORKDIR $HOME

USER kubectl
