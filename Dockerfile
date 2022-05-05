FROM ubuntu:20.04
RUN apt-get update
RUN apt-get -y install curl git apt-transport-https ca-certificates gnupg lsb-release sudo

#RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
#RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
#RUN apt-get update && apt-get -y install google-cloud-cli

RUN curl -O --remote-name https://dl.google.com/go/go1.18.1.linux-amd64.tar.gz
RUN tar -C /usr/local -xzf go1.18.1.linux-amd64.tar.gz
ENV PATH=$PATH:/usr/local/go/bin

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata
RUN apt-get install -y software-properties-common
RUN sudo add-apt-repository ppa:deadsnakes/ppa
RUN apt install -y python3.7 python3.7-dev nodeenv

RUN git clone https://github.com/google/clusterfuzz.git /clusterfuzz
WORKDIR /clusterfuzz

ENV PYTHON=python3.7
RUN apt-get -y install python3.7-distutils
COPY ../install_dependencies.bash /tmp/install_dependencies.bash
RUN chmod +x /tmp/install_dependencies.bash
RUN /tmp/install_dependencies.bash

COPY scripts/ /scripts/
RUN chmod +x /scripts/*.sh

ENTRYPOINT bash