FROM jenkins/jenkins:2.479.3-lts

USER root

ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY

RUN apt-get update && apt-get install -y wget unzip curl python3 python3-pip gnupg && rm -rf /var/lib/apt/lists/*

RUN wget --quiet https://releases.hashicorp.com/terraform/1.12.0/terraform_1.12.0_linux_amd64.zip \
  && unzip terraform_1.12.0_linux_amd64.zip \
  && mv terraform /usr/bin \
  && rm terraform_1.12.0_linux_amd64.zip

RUN apt-get update && \
    apt-get install -y curl python3 && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install
    
RUN apt-get install -y ansible

RUN if ! command -v infisical &> /dev/null; then \
    curl -1sLf 'https://artifacts-cli.infisical.com/setup.deb.sh' | bash && \
    apt-get update && apt-get install -y infisical; \
    fi

USER jenkins
RUN mkdir -p /var/jenkins_home/.ssh && \
    chmod 700 /var/jenkins_home/.ssh && \
    ssh-keygen -t ed25519 -f /var/jenkins_home/.ssh/demo1Ec2Key && \
    chmod 600 /var/jenkins_home/.ssh/demo1Ec2Key && \
    chmod 644 /var/jenkins_home/.ssh/demo1Ec2Key.pub

RUN mkdir -p ~/.aws && \
    echo "[cursor]\naws_access_key_id = ${AWS_ACCESS_KEY_ID}\naws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}" > ~/.aws/credentials


