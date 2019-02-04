FROM atlassian/bamboo-agent-base

USER root

RUN DEBIAN_FRONTEND=noninteractive && \
    apt-get -y update && \
    apt-get -y upgrade && \
    apt-get -y install locales curl wget apt-transport-https python3 python3-pip jq git lsb-release && \
    apt-get clean && \
    AZ_REPO=$(lsb_release -cs) && \
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | tee /etc/apt/sources.list.d/azure-cli.list && \
    curl -L "https://packages.microsoft.com/keys/microsoft.asc" | apt-key add - && \
    apt-get -y update && \
    apt-get -y install azure-cli && \
    apt-get clean && \
    pip3 --no-cache-dir install databricks-cli && \
    cd /usr/bin && ln -fs python3 python && \
    cd /usr/bin && ln -fs pip3 pip && \
    cd /opt && \
    curl --progress-bar --location 'https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/5.0.7/flyway-commandline-5.0.7-linux-x64.tar.gz' | tar -xvzf - && \
    chown ${BAMBOO_USER}:${BAMBOO_USER} -R /opt/flyway-5.0.7 && \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

ENV LANG en_US.UTF-8

USER ${BAMBOO_USER}

RUN echo 'export PATH="$PATH:/opt/flyway-5.0.7"' >> ~/.bashrc
RUN ${BAMBOO_USER_HOME}/bamboo-update-capability.sh "system.git.executable" /usr/bin/git
RUN ${BAMBOO_USER_HOME}/bamboo-update-capability.sh "system.python.executable" /usr/bin/python
RUN ${BAMBOO_USER_HOME}/bamboo-update-capability.sh "system.pip.executable" /usr/bin/pip
RUN ${BAMBOO_USER_HOME}/bamboo-update-capability.sh "system.jq.executable" /usr/bin/jq
RUN ${BAMBOO_USER_HOME}/bamboo-update-capability.sh "system.az.executable" /usr/bin/az
RUN ${BAMBOO_USER_HOME}/bamboo-update-capability.sh "system.databricks.executable" /usr/local/bin/databricks
RUN ${BAMBOO_USER_HOME}/bamboo-update-capability.sh "system.flyway.executable" /opt/flyway-5.0.7/flyway
