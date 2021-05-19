# Docker image for Dovecot + Exim + ttyd

This docker image contains all the components to experiment with the mail protocols SMTP, POP3, IMAP. It is based on Dovecot and Exim.

All components are configured for rootless operation, as this is necessary in some shared container environments.

ttyd allows access to the shell through the browser.

The Docker repository is [fknipp/docker-dovecot-exim-ttyd](https://hub.docker.com/repository/docker/fknipp/docker-dovecot-exim-ttyd).

## Commands to build and publish image

    docker build -t fknipp/docker-dovecot-exim-ttyd .
    docker push fknipp/docker-dovecot-exim-ttyd