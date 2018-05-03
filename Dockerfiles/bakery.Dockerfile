FROM golang:alpine

# #update the image 
# RUN apk update \ 
#     &&   apk add ca-certificates wget zip unzip sudo bash \
#     &&   update-ca-certificates 

# #install ansible 
# RUN apk add ansible

# # Download packer

# RUN wget https://releases.hashicorp.com/packer/1.2.1/packer_1.2.1_linux_amd64.zip
# RUN unzip packer_1.2.1_linux_amd64.zip -d packer
# RUN packer
# RUN sudo mv packer /usr/bin/packer

# #Download terraform
# RUN wget https://releases.hashicorp.com/terraform/0.11.3/terraform_0.11.3_linux_amd64.zip
# RUN unzip terraform_0.11.3_linux_amd64.zip -d terraform
# RUN sudo mv terraform /usr/local/bin/

# RUN sudo packer

ENV TERRAFORM_VERSION=0.10.0

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

RUN apk add py-pip
RUN apk add gcc git libffi-dev musl-dev openssl-dev perl py-pip python python-dev sshpass
RUN apk add make
RUN pip install ansible