FROM rockylinux:9-minimal

# Update rockylinux and install required packages
RUN microdnf -y update && microdnf clean all 
RUN microdnf -y install vim wget tar unzip findutils git procps sudo

# Create the gitsense user
RUN adduser gitsense

# Grab packages from GitHub
RUN cd /opt && git clone --branch beta-1.0.0 https://github.com/gitsense/devboard.git gitsense-app 
RUN cd /opt/gitsense-app/packages && git clone --branch alpha-1.0.0 https://gitsense:{{GH_TOKEN}}@github.com/gitsense/docs.git gitsense-docs
RUN cd /opt/gitsense-app/packages && git clone --branch msg-0.0.0 https://github.com/gitsense/issues.git gitsense-issues
RUN cd /opt/gitsense-app/packages && git clone --branch msg-0.0.0 https://github.com/gitsense/insights.git gitsense-insights
RUN cd /opt/gitsense-app/packages && git clone --branch msg-0.0.0 https://github.com/gitsense/pull-requests.git gitsense-pull-requests

# Simple symlinks
RUN cd /opt && ln -s gitsense-app/packages/gitsense-docs/widgets/app/ docs

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

# Install container scripts as root
USER root
COPY entry gsapp /usr/bin
RUN chmod 755 /usr/bin/entry /usr/bin/gsapp
ENTRYPOINT ["entry"]
