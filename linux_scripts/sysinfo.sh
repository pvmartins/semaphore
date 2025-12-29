#!/bin/bash

echo "=================================================================================================="
echo "                  Welcome to $(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '"')! "
echo "=================================================================================================="

# Get load averages
IFS=" " read LOAD1 LOAD5 LOAD15 <<EOF
$(awk '{ print $1,$2,$3 }' /proc/loadavg)
EOF

# Get memory info
IFS=" " read TOTAL USED FREE <<EOF
$(free -m | awk '/Mem:/ { print $2, $3, $4 }')
EOF
AVAIL=$FREE

# Get processes
PROCESS=$(ps -eo user= | sort | uniq -c | awk '{ print $2 " " $1 }')
PROCESS_ALL=$(echo "$PROCESS" | awk '{print $2}' | awk '{ SUM += $1} END { print SUM }')
PROCESS_ROOT=$(echo "$PROCESS" | grep "^root" | awk '{print $2}')
PROCESS_USER=$(echo "$PROCESS" | grep -v "^root" | awk '{print $2}' | awk '{ SUM += $1} END { print SUM }')

# Get processor info
PROCESSOR_NAME=$(grep "model name" /proc/cpuinfo | cut -d ':' -f2- | sed 's/^ *//' | head -1)
PROCESSOR_COUNT=$(grep -c "^processor" /proc/cpuinfo)

W="\e[0;39m"
G="\e[1;32m"

echo -e "
${W}System info:
$W  Distro......: $(grep PRETTY_NAME /etc/os-release | cut -d= -f2- | tr -d '"')
$W  Kernel......: $(uname -sr)
$W  Uptime......: $(uptime | awk -F'( up |,)' '{print $2}')
$W  Load........: $G$LOAD1$W (1m), $G$LOAD5$W (5m), $G$LOAD15$W (15m)
$W  Processes...: $G$PROCESS_ROOT$W (root), $G$PROCESS_USER$W (user), $G$PROCESS_ALL$W (total)
$W  CPU.........: $PROCESSOR_NAME ($G$PROCESSOR_COUNT$W vCPU)
$W  Memory......: $G$USED$W used, $G$AVAIL$W avail, $G$TOTAL$W total$W"

echo "====================================================================================="

# service check using rc-service
COLUMNS=3
green="\e[1;32m"
red="\e[1;31m"
undim="\e[0m"

services=("sshd" "nginx" "docker" "crond" "fail2ban" "postfix" "apache2" "mysql" "ufw")

# Sort and prepare list
IFS=$'\n' services=($(sort <<<"${services[*]}"))
unset IFS

out=""
for i in "${!services[@]}"; do
    svc="${services[$i]}"
    if rc-service "$svc" status >/dev/null 2>&1; then
        out+="${svc}:,${green}active${undim},"
    else
        out+="${svc}:,${red}inactive${undim},"
    fi
    if [ $((($i + 1) % COLUMNS)) -eq 0 ]; then
        out+="\n"
    fi
done
out+="\n"

printf "\nservices:\n"
printf "$out" | column -ts $',' | sed -e 's/^/  /'
echo "====================================================================================="
