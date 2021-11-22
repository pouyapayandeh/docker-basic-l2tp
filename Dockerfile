FROM alpine:edge
LABEL maintainer=""

RUN apk add --no-cache ca-certificates bash xl2tpd iptables \
	&& rm -rf /var/cache/apk/*

COPY ./etc/xl2tpd/xl2tpd.conf /etc/xl2tpd/xl2tpd.conf
COPY ./etc/ppp/options.xl2tpd /etc/ppp/options.xl2tpd 

COPY entrypoint.sh /usr/bin/entrypoint
RUN chmod 0700 /usr/bin/entrypoint

EXPOSE 500/udp 4500/udp

CMD ["entrypoint"]