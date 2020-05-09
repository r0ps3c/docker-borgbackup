FROM python:alpine as builder
ENV PYTHONUNBUFFERED 1
ENV BORGBACKUP_VER 1.1.11
RUN \
	apk --no-cache add build-base python3-dev acl-dev attr-dev openssl-dev linux-headers libffi-dev && \
	wget https://github.com/borgbackup/borg/releases/download/${BORGBACKUP_VER}/borgbackup-${BORGBACKUP_VER}.tar.gz && \
	tar xf borgbackup-${BORGBACKUP_VER}.tar.gz && \
	cd borgbackup-${BORGBACKUP_VER} && \
	pip3 install -r requirements.d/development.txt && \
	pip3 wheel -w /wheels .

FROM alpine
COPY --from=builder /wheels /wheels

RUN \
	apk --no-cache add python3 openssh-client libacl && \
    	pip3 install -f /wheels borgbackup && \
    	rm -fr /var/cache/apk/* /wheels /.cache

WORKDIR /
ENTRYPOINT ["/usr/bin/borg"]
