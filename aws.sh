#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# enable interruption signal handling
trap - INT TERM

if [[ ! -d "${HOME}/.aws" ]]; then
	mkdir -p "${HOME}/.aws"
	chown -R ${UID}:${GID} "${HOME}/.aws"
fi

docker run --rm \
	-t $(tty &>/dev/null && echo "-i") \
	$([[ -n "${AWS_ACCESS_KEY_ID:-}" ]] && echo "-e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}" || true) \
	$([[ -n "${AWS_SECRET_ACCESS_KEY:-}" ]] && echo "-e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" || true) \
	$([[ -n "${AWS_DEFAULT_REGION:-}" ]] && echo "-e AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}" || true) \
	-v "$(pwd):/project" \
	-v "${HOME}/.aws:/root/.aws"
	mesosphere/aws-cli \
	"$@"
