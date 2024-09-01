export NVM_DIR="$HOME/.nvm" && \
source "$NVM_DIR/nvm.sh" && \

cd /opt/gitsense-app/packages/gitsense-docs/widgets/app && forever start manager.js;
cd /opt/gitsense-app && forever start server.js;

