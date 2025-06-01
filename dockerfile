FROM jenkins/jenkins:2.479.3-lts

USER root

RUN apt-get update && apt-get install -y \
    wget \
    unzip \
  && rm -rf /var/lib/apt/lists/*

RUN wget --quiet https://releases.hashicorp.com/terraform/1.12.0/terraform_1.12.0_linux_amd64.zip \
  && unzip terraform_1.12.0_linux_amd64.zip \
  && mv terraform /usr/bin \
  && rm terraform_1.12.0_linux_amd64.zip

RUN apt-get update && \
    apt-get install -y curl python3 && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install

RUN mkdir -p ~/.ssh && \
    chmod 700 ~/.ssh && \
    ssh-keygen -t ed25519 -f ~/.ssh/demo1Ec2Key -N '' && \
    chmod 600 ~/.ssh/demo1Ec2Key && \
    chmod 644 ~/.ssh/demo1Ec2Key.pub



