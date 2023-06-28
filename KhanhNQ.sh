#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-or-later
# ======================================================================
# Constants

red() {
  echo -e "\033[31m\033[01m$1\033[0m"
}

green() {
  echo -e "\033[32m\033[01m$1\033[0m"
}

yellow() {
  echo -e "\033[33m\033[01m$1\033[0m"
}

REGEX=("debian" "ubuntu" "centos|red hat|kernel|oracle linux|alma|rocky" "'amazon linux'")
RELEASE=("Debian" "Ubuntu" "CentOS" "CentOS" "Alpine")
PACKAGE_UPDATE=("apt -y update" "apt -y update" "yum -y update" "yum -y update")
PACKAGE_INSTALL=("apt -y install" "apt -y install" "yum -y install" "yum -y install" "apk add -f")
PACKAGE_REMOVE=("apt -y remove" "apt -y remove" "yum -y remove" "yum -y remove")

CMD=("$(grep -i pretty_name /etc/os-release 2>/dev/null | cut -d \" -f2)" "$(hostnamectl 2>/dev/null | grep -i system | cut -d : -f2)" "$(lsb_release -sd 2>/dev/null)" "$(grep -i description /etc/lsb-release 2>/dev/null | cut -d \" -f2)" "$(grep . /etc/redhat-release 2>/dev/null)" "$(grep . /etc/issue 2>/dev/null | cut -d \\ -f1 | sed '/^[ ]*$/d')")

for i in "${CMD[@]}"; do
  SYS="$i" && [[ -n $SYS ]] && break
done

for ((int = 0; int < ${#REGEX[@]}; int++)); do
  [[ $(echo "$SYS" | tr '[:upper:]' '[:lower:]') =~ ${REGEX[int]} ]] && SYSTEM="${RELEASE[int]}" && [[ -n $SYSTEM ]] && break
done

[[ -z $SYSTEM ]] && red "Error!" && exit 1

archAffix() {
  case "$(uname -m)" in
  x86_64 | x64 | amd64) return 0 ;;
  aarch64 | arm64) return 0 ;;
  *) red "Error！" ;;
  esac

  return 0
}

install() {
  install_XrayR
  clear
  makeConfig
}

install_XrayR() {
  [[ -z $(type -P curl) ]] && ${PACKAGE_UPDATE[int]} && ${PACKAGE_INSTALL[int]} curl
  [[ -z $(type -P socat) ]] && ${PACKAGE_UPDATE[int]} && ${PACKAGE_INSTALL[int]} socat
  bash <(curl -Ls https://raw.githubusercontent.com/XrayR-project/XrayR-release/master/install.sh)
  sudo ufw allow 80/tcp
  sudo ufw allow 443/tcp
  sudo ufw allow 80
  sudo ufw allow 443
}

makeConfig() {
  echo "------  free1s.click ---------"
  echo -p "Loại website của bạn: V2board"
  echo "---------------"
  echo -p "Link website: https://free1s.click"
  echo "---------------"
  echo -p "API key của web: khanhnq0989050605"
  echo "---------------"
  read -p "Node ID 80: " NodeID80
  echo -e "Node 80 là: ${NodeID80}"
  echo "---------------"

  rm -f /etc/XrayR/config.yml
  if [[ -z $(~/.acme.sh/acme.sh -v 2>/dev/null) ]]; then
    curl https://get.acme.sh | sh -s email=script@github.com
    source ~/.bashrc
    bash ~/.acme.sh/acme.sh --upgrade --auto-upgrade
  fi
  cat <<EOF >/etc/XrayR/config.yml
Log:
  Level: none 
  AccessPath: # /etc/XrayR/access.Log
  ErrorPath: # /etc/XrayR/error.log
DnsConfigPath: # /etc/XrayR/dns.json
InboundConfigPath: # /etc/XrayR/custom_inbound.json
RouteConfigPath: # /etc/XrayR/route.json
OutboundConfigPath: # /etc/XrayR/custom_outbound.json
ConnetionConfig:
  Handshake: 4 
  ConnIdle: 30 
  UplinkOnly: 2 
  DownlinkOnly: 4 
  BufferSize: 64 
Nodes:
  -
    PanelType: "V2board" 
    ApiConfig:
      ApiHost: "https://free1s.click"
      ApiKey: "khanhnq0989050605"
      NodeID: $NodeID80
      NodeType: V2ray 
      Timeout: 30 
      EnableVless: false 
      EnableXTLS: false 
      SpeedLimit: 0
      DeviceLimit: 0
      RuleListPath: # /etc/XrayR/rulelist
    ControllerConfig:
      DisableSniffing: True
      ListenIP: 0.0.0.0 
      SendIP: 0.0.0.0 
      UpdatePeriodic: 60 
      EnableDNS: false 
      DNSType: AsIs 
      EnableProxyProtocol: false 
      EnableFallback: false 
      FallBackConfigs:  
        -
          SNI: 
          Path: 
          Dest: 80 
          ProxyProtocolVer: 0 
      CertConfig:
        CertMode: none
        CertDomain: none.example.com
        CertFile: /etc/XrayR/cert-net/cert.crt
        KeyFile: /etc/XrayR/cert-net/key.key
        Provider: alidns
        Email: test@me.com
        DNSEnv: 
          ALICLOUD_ACCESS_KEY: aaa
          ALICLOUD_SECRET_KEY: bbb

EOF
  cd /etc/XrayR
  git clone https://github.com/SmileyRambo/Yolo.git
  XrayR restart
  green "Đã xong, vui lòng reboot thiết bị！"
  exit 1
}

install
