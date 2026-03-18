#!/bin/sh
set -e

EMBED_DELAY="${BEDROCK_STUB_EMBED_DELAY_MS:-50}"
CONVERSE_DELAY="${BEDROCK_STUB_CONVERSE_DELAY_MS:-50}"

MAPPINGS_DIR="/home/wiremock/mappings"

# Patch embed.json
if [ -f "${MAPPINGS_DIR}/embed.json" ]; then
  jq --argjson delay "$EMBED_DELAY" '.mappings[0].response.fixedDelayMilliseconds = $delay' \
    "${MAPPINGS_DIR}/embed.json" > "${MAPPINGS_DIR}/embed.json.tmp" && \
    mv "${MAPPINGS_DIR}/embed.json.tmp" "${MAPPINGS_DIR}/embed.json"
fi

# Patch converse.json (both mappings)
if [ -f "${MAPPINGS_DIR}/converse.json" ]; then
  jq --argjson delay "$CONVERSE_DELAY" '
    .mappings[0].response.fixedDelayMilliseconds = $delay |
    .mappings[1].response.fixedDelayMilliseconds = $delay
  ' "${MAPPINGS_DIR}/converse.json" > "${MAPPINGS_DIR}/converse.json.tmp" && \
    mv "${MAPPINGS_DIR}/converse.json.tmp" "${MAPPINGS_DIR}/converse.json"
fi

exec /docker-entrypoint.sh "$@"
