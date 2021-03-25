FROM centos:7

MAINTAINER  Tomas Jelinek "jelkosz@gmail.com"

USER root

##################### default deps #####################

RUN yum update -y && yum install -y git wget gcc

##################### nodejs #####################

RUN curl -sL https://rpm.nodesource.com/setup_14.x | bash -

RUN yum install -y nodejs

##################### yarn #####################

RUN curl --silent --location https://dl.yarnpkg.com/rpm/yarn.repo | tee /etc/yum.repos.d/yarn.repo

RUN rpm --import https://dl.yarnpkg.com/rpm/pubkey.gpg

RUN yum install -y yarn

##################### go #####################

RUN wget https://dl.google.com/go/go1.13.3.linux-amd64.tar.gz

RUN tar -xzf go1.13.3.linux-amd64.tar.gz

RUN mv go /usr/local

RUN mkdir srcs

ENV GOROOT "/usr/local/go"

ENV GOPATH "$HOME"

ENV PATH "$GOPATH/bin:$GOROOT/bin:$PATH"

#RUN git clone https://github.com/openshift/console.git

#RUN cd console && ./build.sh 

#RUN source ./contrib/oc-environment.sh

##################### oc #####################

RUN wget https://github.com/openshift/origin/releases/download/v1.5.1/openshift-origin-client-tools-v1.5.1-7b451fc-linux-64bit.tar.gz

RUN tar xf openshift-origin-client-tools-v1.5.1-7b451fc-linux-64bit.tar.gz

RUN cp openshift-origin-client-tools-v1.5.1-7b451fc-linux-64bit/oc /bin

##################### jq #####################

RUN yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

RUN yum install jq -y

##################### clone and build #####################

RUN git clone https://github.com/openshift/console.git

RUN cd console && ./build.sh 
