FROM debian:buster
LABEL maintainer "Franz Knipp <franz.knipp@fh-burgenland.at>"

ARG DEBIAN_FRONTEND=noninteractive
ENV LC_ALL C

# Install supervisord and CA certificates

RUN apt-get -y update && \
    apt-get -y install ca-certificates supervisor

# Install and configure Exim

RUN apt-get -y install exim4

ADD exim4.conf /etc/exim4/exim4.conf

# Install Dovecot

ADD dovecot.list /etc/apt/sources.list.d/dovecot.list
ADD dovecot.gpg /etc/apt/trusted.gpg.d/dovecot.gpg

RUN apt-get -y update && \
    apt-get -y install \
        dovecot-core \
        dovecot-coi \
        # dovecot-gssapi \
        dovecot-imapd \
        dovecot-ldap \
        dovecot-lmtpd \
        # dovecot-lua \
        dovecot-managesieved \
        # dovecot-mysql \
        # dovecot-pgsql \
        dovecot-pop3d \
        dovecot-sieve \
        # dovecot-solr \
        # dovecot-sqlite \
        dovecot-submissiond \
        ca-certificates \
        ssl-cert && \
    rm -rf /etc/dovecot && \
    mkdir /srv/mail && \
    chown Debian-exim: /srv/mail && \
    make-ssl-cert generate-default-snakeoil && \
    mkdir /etc/dovecot && \
    cp /etc/ssl/certs/ssl-cert-snakeoil.pem /etc/dovecot/cert.pem && \
    cp /etc/ssl/private/ssl-cert-snakeoil.key /etc/dovecot/key.pem

ADD dovecot.conf /etc/dovecot/dovecot.conf

# Install additional tools

RUN apt-get -y install netcat less man nano procps net-tools

# Install ttyd for access via browser

RUN apt-get -y install curl && \
    curl -L https://github.com/tsl0922/ttyd/releases/download/1.6.3/ttyd.x86_64 > /usr/local/bin/ttyd && \
    chmod a+x /usr/local/bin/ttyd

EXPOSE 3000

# Run everything

COPY supervisord.conf /etc/supervisor/supervisord.conf

# Run as non-root user

RUN touch /supervisord.log /supervisord.pid && \
    mkdir /var/run/dovecot && \
    chown Debian-exim: /supervisord.log /supervisord.pid && \
    chown -R Debian-exim: /etc/dovecot /var/run/dovecot /var/lib/dovecot /var/log/exim4

# This is the user Debian-exim

USER 101 

CMD ["/usr/bin/supervisord"]