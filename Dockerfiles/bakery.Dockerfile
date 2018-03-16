FROM golang:alpine

ENV TERRAFORM_VERSION=0.11.3

RUN apk add --update git bash openssh

ENV TF_DEV=true
ENV TF_RELEASE=true

# Clone and build terraform
WORKDIR $GOPATH/src/github.com/hashicorp/terraform
RUN git clone https://github.com/hashicorp/terraform.git ./ && \
    git checkout v${TERRAFORM_VERSION} && \
    /bin/bash scripts/build.sh

#clone and build packer
RUN go get github.com/mitchellh/gox
RUN go get github.com/hashicorp/packer
WORKDIR $GOPATH/src/github.com/hashicorp/packer
RUN go build -o bin/packer .

# install ansible and dependencies
RUN apk update
RUN apk add sudo make gcc git libffi-dev musl-dev openssl-dev perl py-pip python python-dev sshpass
RUN pip install ansible
RUN ansible --version

RUN adduser -S baker -s /bin/bash -h /home/baker
USER baker
RUN mkdir ~/.ssh
WORKDIR /home/baker