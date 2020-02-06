FROM amd64/alpine

ENV DHCP_VER=4.4.2-r0 \
    BUILD_DATE=20200206T153148 \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    PARAMS=""

LABEL build_version="Build-date: ${BUILD_DATE}"
LABEL maintainer="Lucas Halbert <lhalbert@lhalbert.xyz>"
MAINTAINER Lucas Halbert <lhalbert@lhalbert.xyz>


# Add s6 overlay
ADD https://github.com/just-containers/s6-overlay/releases/download/v1.22.1.0/s6-overlay-amd64.tar.gz /tmp/
RUN tar -xf /tmp/s6-overlay-amd64.tar.gz -C /

RUN apk add --no-cache --update shadow bash tzdata dhcp \
    && apk del --purge \
    && touch /var/lib/dhcp/dhcpd.leases \
    && rm -rf /var/cache/apk/* /tmp/* \
    && groupmod -g 1000 users \
    && useradd -u 911 -U -d /var/lib/dhcp -s /bin/false abc \
    && usermod -G users abc 

ADD ./etc /etc

VOLUME /etc/dhcp/


# Expose DHCP ports
EXPOSE 67/udp 67/tcp

# Expose DHCP failover peer port
EXPOSE 647/udp 647/tcp

# Expose DHCP OMAPI ports
expose 7911/udp 7911/tcp

# s6 overlay entrypoint
ENTRYPOINT ["/init"]
