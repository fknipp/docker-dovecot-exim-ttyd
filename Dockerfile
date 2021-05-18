FROM debian:buster
LABEL maintainer "Franz Knipp <franz.knipp@fh-burgenland.at>"

ARG DEBIAN_FRONTEND=noninteractive
ENV LC_ALL C

# Install supervisord and CA certificates

RUN apt-get -y update && \
    apt-get -y install ca-certificates supervisor

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
    groupadd -g 1000 vmail && \
    useradd -u 1000 -g 1000 vmail -d /srv/vmail && \
    passwd -l vmail && \
    rm -rf /etc/dovecot && \
    # chmod +x /sbin/tini && \
    mkdir /srv/mail && \
    chown vmail:vmail /srv/mail && \
    make-ssl-cert generate-default-snakeoil && \
    mkdir /etc/dovecot && \
    ln -s /etc/ssl/certs/ssl-cert-snakeoil.pem /etc/dovecot/cert.pem && \
    ln -s /etc/ssl/private/ssl-cert-snakeoil.key /etc/dovecot/key.pem

ADD dovecot.conf /etc/dovecot/dovecot.conf

VOLUME ["/etc/dovecot", "/srv/mail"]

# Install Postfix

# Install additional tools

RUN apt-get -y install netcat

# Install wetty for access via browser

ADD nodesource.list /etc/apt/sources.list.d/nodesource.list

RUN apt-get -y install curl gnupg build-essential && \
    curl -sSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - && \
    apt-get update && \
    apt-get install nodejs && \
    npx yarn global add wetty

EXPOSE 3000

# Run everything

COPY supervisord.conf /etc/supervisor/supervisord.conf
CMD ["/usr/bin/supervisord"]