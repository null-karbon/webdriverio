FROM node:15

LABEL MAINTAINER="nullKarbon"

# Set proxy for apt if necessary
#ARG https_proxy=http://myproxy.com:80
#ARG http_proxy=http://myproxy.com:80
#ARG no_proxy=.test.com

RUN apt-get update && apt-get upgrade -y && apt-get install -q -y --fix missing \
    g++ \
    vim \
    build-essential \
    apt-transport-https
    
# Install latest Chrome
RUN curl -sS -o https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add
RUN echo "deb https://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list
RUN apt-get update && apt-get install -q -y --fix-missing \
    google-chrome-stable && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
    
# Remove because container scanners complain about it
RUN rm /usr/share/doc/libnet-ssleay-perl/examples/server_key.pem

# Run as a less privileged user
USER node

# Create a directory where all node packages and test will be executed from
RUN mkdir /tmp/wdio-test
WORKDIR /tmp/wdio-test

# Set proxy for NPM if necessary
#RUN npm config set https-proxy http://myproxy.com:80 && npm config set http-proxy http://myproxy.com:80

# Set npm registry
RUN npm config set registry http://registry.npmjs.org

# Initialize npm directory
RUN npm init -y

# Install WebdriverIO CLI
RUN npm i --save-dev @wdio/cli

# Generate config
RUN npx wdio config -y

# Copy over a configured conf.js to replace the default.
COPY wdio.conf.js wdio.conf.js

# Create spec directory to hold tests
RUN mkdir -p ./test/specs

# Remove another example flagged by container scanners.
RUN rm /tmp/wdio-test/node_modules/lazystream/secret

CMD ["/bin/bash"]
