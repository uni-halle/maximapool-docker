#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'
MAXIMA_POOL_EP="http://127.0.0.1:8080/MaximaPool/MaximaPool"
STACK_VERSION=$(<"${MAXIMAPOOL}"/stack-version)

# Low level health check
HTTP_CODE=$(curl \
  -sw '%{http_code}' \
  -o /dev/null \
  --max-time 5 \
  "${MAXIMA_POOL_EP}?healthcheck=1&version=${STACK_VERSION}" \
)
[                -n "$?" ] || exit 1
[ "${HTTP_CODE}" -ge 200 ] && \
[ "${HTTP_CODE}" -lt 300 ] || exit 1

# High level health check
HTTP_CODE=$(curl \
  -sw '%{http_code}' \
  -o /dev/null \
  --max-time 5 \
  -X POST \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "input=1%2B1;&timeout=1000&version=${STACK_VERSION}" \
  "${MAXIMA_POOL_EP}" \
)
[                -n "$?" ] || exit 1
[ "${HTTP_CODE}" -ge 200 ] && \
[ "${HTTP_CODE}" -lt 300 ] || exit 1

RESP=$(curl \
  --max-time 5 \
  -s \
  -X POST \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "input=1%2B1;&timeout=1000&version=${STACK_VERSION}" \
  "${MAXIMA_POOL_EP}" \
)

if echo "$RESP" | grep -qE "o[0-9][^\\(]{1,5}2"; then
	exit 0
else
	exit 1
fi

