FROM rockylinux:9-minimal

# Update rockylinux and install required packages
RUN microdnf -y update && microdnf clean all 
RUN microdnf -y install vim wget tar unzip findutils git procps sudo

# Install the DuckDB binary which is required by GitSense Docs
RUN cd /tmp && \
    wget https://github.com/duckdb/duckdb/releases/download/v1.0.0/duckdb_cli-linux-amd64.zip && \
    unzip duckdb_cli-linux-amd64.zip -d /usr/bin

# Create the gitsense user
RUN adduser gitsense

# Grab packages from GitHub
RUN cd /opt && git clone --branch beta-1.0.0 https://github.com/gitsense/devboard.git gitsense-app 
RUN cd /opt/gitsense-app/packages && git clone --branch beta-1.0.2 https://github.com/gitsense/docs.git gitsense-docs

# See https://devboard.gitsense.com/?board=welcome.boards to learn more about the boards.json file
COPY boards.json /opt/gitsense-app

# Transfer ownership and group for /opt/gitsnse-app to the gitsense user
RUN chgrp -R gitsense /opt/gitsense-app
RUN chown -R gitsense /opt/gitsense-app

# Install node as the gitsense user
USER gitsense
ENV HOME=/home/gitsense
RUN cd /home/gitsense && \
    wget https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh  && \
    bash install.sh && \
    export NVM_DIR="$HOME/.nvm" && \
    source "$NVM_DIR/nvm.sh" && \
    nvm install 20

# Publish gitsense app.  See https://devboard.gitsense.com/?board=welcome.publish to learn more.
RUN export NVM_DIR="$HOME/.nvm" && \
    source "$NVM_DIR/nvm.sh" && \
    cd /opt/gitsense-app && \
    npm install && \
    npm install -g forever && \
    npm run build:widgets && \
    npm run build:boards && \
    npm run bundle

# Make sure to run this as the gitsense user
RUN duckdb -c 'INSTALL SQLITE; LOAD SQLITE;'

# Install start-app which will start necessary processes and keep the container up and running indefinitely
USER root
COPY start.sh start-processes.sh /usr/bin
RUN chmod 755 /usr/bin/start.sh /usr/bin/start-processes.sh
ENTRYPOINT ["start.sh"]
