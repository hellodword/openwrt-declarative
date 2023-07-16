# openwrt-declarative

```sh
. ap/.env

docker pull "openwrt/imagebuilder:$OP_BUILD_TAG"

mkdir "$OP_BUILD_TYPE/bin"

docker run --rm \
    -v "$(pwd)/$OP_BUILD_TYPE/bin":"/builder/bin" \
    -v "$(pwd)/$OP_BUILD_TYPE/files":"/builder/custom-files" \
    -v "$(pwd)/common/files":"/builder/common-files" \
    -v "$(pwd)/$OP_BUILD_TYPE/.env.${OP_HOSTNAME}":"/builder/.env":ro \
    -v "$(pwd)/build.sh":"/builder/build.sh":ro \
    "openwrt/imagebuilder:$OP_BUILD_TAG" \
        bash /builder/build.sh

docker run --rm \
    -it \
    -v "$(pwd)/$OP_BUILD_TYPE/bin":"/builder/bin" \
    -v "$(pwd)/$OP_BUILD_TYPE/files":"/builder/custom-files" \
    -v "$(pwd)/common/files":"/builder/common-files" \
    -v "$(pwd)/$OP_BUILD_TYPE/.env.${OP_HOSTNAME}":"/builder/.env":ro \
    -v "$(pwd)/build.sh":"/builder/build.sh":ro \
    "openwrt/imagebuilder:$OP_BUILD_TAG" \
        bash


# scp -O /path/to/sysupgrade.bin root@<...>:/tmp/sysupgrade.bin
# ssh root@<...>
# sysupgrade -u -n -p -v /tmp/sysupgrade.bin
```

- [ap](./ap): 双频，单网口，OpenWrt 默认没有 wan 口、没有 switch
- [router](./router): 双频，主路由，五网口
- [travel](./travel): 双频，三网口
- [onu](./onu): 光猫

## debug

- 修改前备份 `/etc/config`，设置 cron job，减少搞挂刷机的次数

```
# crontab -e
*/3 * * * * (wget -q -O- --timeout=3 "https://223.5.5.5/resolve?name=example.com&type=AAAA" || wget -q -O- --timeout=3 "https://223.5.5.5/resolve?name=example.com&type=AAAA") || (cp /root/network /etc/config/network; reboot)
```

- tftp

```
tftp 192.168.1.1
> binary
> put factory.img
> quit
```

---

- https://github.com/mwarning/openwrt-examples/blob/51af905de23df41f6024e81aef14a892e5ef8ef6/README.md#automatic-and-generic-wifi-setup
- https://github.com/astro/nix-openwrt-imagebuilder/
- https://imciel.com/2021/03/20/create-configless-openwrt-firmware/
- https://github.com/ekkog/OpenWrt
- https://vxchin.gitbooks.io/openwrt-fanqiang/content/ebook/04.3.html
- https://hub.docker.com/r/openwrt/imagebuilder/tags
