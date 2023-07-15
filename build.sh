#!/bin/bash

set -e
set -x

rm -rf files
rsync -a common-files/ files/
rsync -a custom-files/ files/

mkdir -p files/root
rm -f files/root/.env
cp .env files/root/.env

. .env

[ -n "$OP_PROFILE" ]


# assert OP_
# grep -hroP '(?<=[^a-zA-Z\d_])OP_[A-Z_\d]+' . | sort -n | uniq

[ -n "$OP_HOSTNAME" ]
[ -n "$OP_ROOT_PASSWORD" ]
[ -n "$OP_LAN_IP_PREFIX" ]

[ -n "$OP_WIRELESS_SSID" ]
[ -n "$OP_WIRELESS_PASSWORD" ]

if [ -n "$OP_WIRELESS_GUEST_SSID" ]; then
    [ -n "$OP_WIRELESS_GUEST_PASSWORD" ]
fi

if [ -n "$OP_WIRELESS_IOT_SSID" ]; then
    [ -n "$OP_WIRELESS_IOT_PASSWORD" ]
fi

PACKAGES_ARCH=$(cat .config | grep CONFIG_TARGET_ARCH_PACKAGES | awk -F '=' '{print $2}' | sed 's/"//g')
OPENWRT_VERSION=$(cat ./include/version.mk | grep 'VERSION_NUMBER:=$(if' | awk -F ',' '{print $3}' | awk -F ')' '{print $1}')
BIG_VERSION=$(echo $OPENWRT_VERSION | awk -F '.' '{print $1"."$2}')

echo "PACKAGES_ARCH: $PACKAGES_ARCH OPENWRT_VERSION: $OPENWRT_VERSION BIG_VERSION: $BIG_VERSION"

if [ -f "files/etc/dropbear/authorized_keys" ];then
    chmod 644 files/etc/dropbear/authorized_keys
fi

# 不需要的镜像
sed -i '/CONFIG_ISO_IMAGES/ c\# CONFIG_ISO_IMAGES is not set' .config
sed -i '/CONFIG_TARGET_IMAGES_PAD/ c\# CONFIG_TARGET_IMAGES_PAD is not set' .config
sed -i '/CONFIG_VDI_IMAGES/ c\# CONFIG_VDI_IMAGES is not set' .config
sed -i '/CONFIG_VMDK_IMAGES/ c\# CONFIG_VMDK_IMAGES is not set' .config
sed -i '/CONFIG_VHDX_IMAGES/ c\# CONFIG_VHDX_IMAGES is not set' .config

# base packages
all_packages="-dnsmasq openssl-util"

if [ -z "${OP_DUMP_AP}" ]; then
    all_packages="$all_packages dnsmasq-full luci luci-compat luci-lib-ipkg luci-app-opkg luci-theme-bootstrap luci-lib-base luci-app-firewall"
else
    # TODO remove luci/dropbear/dnsmasq/firewall/dhcp packages from dumpap
    all_packages="$all_packages -uhttpd"
    all_packages="$all_packages -firewall -firewall4"
    all_packages="$all_packages -odhcp6c -odhcpd -odhcpd-ipv6only"
    all_packages="$all_packages -opkg -ppp -ppp-mod-pppoe"
    all_packages="$all_packages -kmod-usb-dwc3 -kmod-usb-dwc3-qcom -kmod-usb3"
    # all_packages="$all_packages -udropbear"
fi

if [ -n "${OP_PACKAGES}" ]; then
    all_packages="$all_packages $OP_PACKAGES"
fi

# printenv | grep 'CONFIG_', export all config
for config in $(printenv | grep '^CONFIG_'); do
    config_name=$(echo $config | awk -F '=' '{print $1}')
    config_value=$(echo $config | awk -F '=' '{print $2}')
    sed -i "/$config_name/ c\\$config_name=$config_value" .config
done


EXTRA_IMAGE_NAME="$OP_HOSTNAME-$(date +%Y-%m-%d-%H-%M-%S)"

# make info

make image PROFILE="$OP_PROFILE" PACKAGES="$all_packages" FILES="files" EXTRA_IMAGE_NAME="$EXTRA_IMAGE_NAME"
