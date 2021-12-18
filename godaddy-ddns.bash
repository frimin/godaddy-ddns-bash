#!/usr/bin/env bash

[[ -a "$1" ]] && source "$1"

GODADDY_DDNS_DEBUG_MODE=${GODADDY_DDNS_DEBUG_MODE:-0}
GODADDY_DDNS_KEY=${GODADDY_DDNS_KEY:?}
GODADDY_DDNS_SECRET=${GODADDY_DDNS_SECRET:?}
GODADDY_DDNS_DOMAIN=${GODADDY_DDNS_DOMAIN:?}
GODADDY_DDNS_NAME=${GODADDY_DDNS_NAME:?}
GODADDY_DDNS_TTL=${GODADDY_DDNS_TTL:-600}
GODADDY_DDNS_IPV6=${GODADDY_DDNS_IPV6:-}
GODADDY_DDNS_GET_IP_URL="${GODADDY_DDNS_GET_IP_URL:-https://icanhazip.com}"
GODADDY_DDNS_INTERVAL="${GODADDY_DDNS_INTERVAL:-300}"

RECORD_TYPE=''

gen_url() {
    echo "https://api.godaddy.com/v1/domains/"${GODADDY_DDNS_DOMAIN}"/records/${RECORD_TYPE}/"${GODADDY_DDNS_NAME}""
}

CURL_COMMON_OPTIONS=(
    -sf
    --connect-timeout 60
    --max-time 60
)

curl=/usr/bin/curl

update_ddns() {
    [[ -z $1 ]] && return 255
    CURL_OPTIONS=(
        -X PUT
        -H "Content-Type: application/json"
        -H "Accept: application/json"
        -H "Authorization: sso-key $GODADDY_DDNS_KEY:$GODADDY_DDNS_SECRET"
    )
    CURL_DATA="[{ \"data\":\"$1\", \"ttl\":$GODADDY_DDNS_TTL, \"name\":\"$GODADDY_DDNS_NAME\", \"type\":\"A\" }]"
    curl "$(gen_url)" "${CURL_OPTIONS[@]}" "${CURL_COMMON_OPTIONS[@]}" -d "$CURL_DATA" 
}

LAST_IP=''
IDX=0

while true; do
    ((++IDX))

    EXT_OPTIONS=()

    if [[ $GODADDY_DDNS_IPV6 == '1' ]]; then
        EXT_OPTIONS+=('-6')
    else
        EXT_OPTIONS+=('-4')
    fi

    echo "#${IDX} Get ip address from $GODADDY_DDNS_GET_IP_URL"

    IP="$(curl "$GODADDY_DDNS_GET_IP_URL" "${CURL_COMMON_OPTIONS[@]}" ${EXT_OPTIONS[@]})"

    if ip -4 route get "$IP" >/dev/null 2>&1; then
        RECORD_TYPE='A'
    elif ip -6 route get "$IP"/128 >/dev/null 2>&1; then
        RECORD_TYPE='AAAA'
    else
        echo "#${IDX} Get ip failed, try later" >&2
        sleep "$GODADDY_DDNS_INTERVAL"
    fi

    if [[ "$IP" == "$LAST_IP" ]]; then
        sleep "$GODADDY_DDNS_INTERVAL"
        continue
    fi

    if update_ddns "$IP" ; then
        echo "#${IDX} Update domain record succeeded, ${GODADDY_DDNS_NAME}.$GODADDY_DDNS_DOMAIN=$IP"
        LAST_IP="$IP"
    else
        echo "#${IDX} Update domian record failed, try later" >&2
    fi

    sleep "$GODADDY_DDNS_INTERVAL"
done

