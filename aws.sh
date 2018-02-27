#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# enable interruption signal handling
trap - INT TERM

if [[ ! -d "${HOME}/.aws" ]]; then
	mkdir -p "${HOME}/.aws"
	chown -R ${UID}:$(id -g ${UID}) "${HOME}/.aws"
fi

DOCKER_ARGS=""

# I/O Detection for TTY
# This allows use in subshells without CRLF line-endings from TTY.
if [ -t 0 ] && [ -t 1 ]; then
	DOCKER_ARGS+=" -t"
fi

# TTY Detection for Interactivity
# This allows input in all but non-interactive shells.
if tty -s; then
	DOCKER_ARGS+=" -i"
fi

# AWS Environment Variables
# Pass through all AWS variables, including session tokens and role assumption.
while read line; do
	DOCKER_ARGS+=" -e ${line}"
done < <(env | grep "AWS_")

docker run --rm \
	${DOCKER_ARGS} \
	-v "$(pwd):/project" \
	-v "${HOME}/.aws:/root/.aws" \
	karlkfi/aws-cli \
	"$@"
