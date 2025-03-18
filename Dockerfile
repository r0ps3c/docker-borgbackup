ARG BORGBACKUP_VER=1.2.7 # set default value
FROM alpine AS build
ARG BORGBACKUP_VER # Redeclare to make it available
ENV PYTHONUNBUFFERED=1
RUN \
	apk --no-cache add build-base python3-dev acl-dev attr-dev openssl-dev linux-headers libffi-dev py3-pip pkgconfig py3-wheel py3-packaging py3-msgpack && \
	wget -q https://github.com/borgbackup/borg/releases/download/$BORGBACKUP_VER/borgbackup-$BORGBACKUP_VER.tar.gz && \
	tar xf borgbackup-${BORGBACKUP_VER}.tar.gz && \
	cd borgbackup-${BORGBACKUP_VER} && \
	apk --no-cache add `awk '{print $1}' requirements.d/development.txt | while read -r line; do case "$line" in Cython) printf \
		cython;; pre-commit) printf $line;; python-dateutil) printf py3-dateutil;; *) printf "py3-$line";; esac; printf " "; done` && \
	pip wheel -w /wheels .

FROM alpine
COPY --from=build /wheels /wheels
ARG BORGBACKUP_VER # Redeclare to make it available in this stage
RUN \
	ls -l /wheels && \
	apk --no-cache add python3 py3-pip openssh-client acl-libs py3-packaging py3-msgpack && \
    pip install --break-system-packages --find-links /wheels borgbackup==$BORGBACKUP_VER  && \
	apk del py3-pip py3-pip-pyc && \
    rm -fr /var/cache/apk/* /wheels /.cache

WORKDIR /
ENTRYPOINT ["/usr/bin/borg"]
