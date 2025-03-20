#!/bin/sh

export BORG_PASSPHRASE=""
borg init --encryption=keyfile /tmp/borgtest
