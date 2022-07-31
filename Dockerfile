ARG BORGBACKUP_VER=1.1.18
FROM alpine as build
ENV PYTHONUNBUFFERED=1
ARG BORGBACKUP_VER
RUN \
	apk --no-cache add build-base python3-dev acl-dev attr-dev openssl-dev linux-headers libffi-dev py3-pip pkgconfig && \
	wget https://github.com/borgbackup/borg/releases/download/$BORGBACKUP_VER/borgbackup-$BORGBACKUP_VER.tar.gz && \
	tar xf borgbackup-${BORGBACKUP_VER}.tar.gz && \
	cd borgbackup-${BORGBACKUP_VER} && \
	pip install -r requirements.d/development.txt && \
	pip install wheel && \
	pip wheel -w /wheels .

FROM alpine
COPY --from=build /wheels /wheels
ARG BORGBACKUP_VER
RUN \
	apk --no-cache add python3 py3-pip openssh-client libacl && \
    	pip install --find-links /wheels borgbackup==$BORGBACKUP_VER packaging && \
    	rm -fr /var/cache/apk/* /wheels /.cache

WORKDIR /
ENTRYPOINT ["/usr/bin/borg"]
