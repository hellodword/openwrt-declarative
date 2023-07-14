# openwrt-declarative

```sh
. ap/.env

docker pull "openwrt/imagebuilder:$BUILD_TAG"

mkdir "$BUILD_TYPE/bin"

docker run --rm \
    -v "$(pwd)/$BUILD_TYPE/bin":"/builder/bin" \
    -v "$(pwd)/$BUILD_TYPE/files":"/builder/custom-files" \
    -v "$(pwd)/common/files":"/builder/common-files" \
    -v "$(pwd)/$BUILD_TYPE/.env":"/builder/.env":ro \
    -v "$(pwd)/build.sh":"/builder/build.sh":ro \
    "openwrt/imagebuilder:$BUILD_TAG" \
        bash /builder/build.sh

docker run --rm \
    -it \
    -v "$(pwd)/$BUILD_TYPE/bin":"/builder/bin" \
    -v "$(pwd)/$BUILD_TYPE/files":"/builder/custom-files" \
    -v "$(pwd)/common/files":"/builder/common-files" \
    -v "$(pwd)/$BUILD_TYPE/.env":"/builder/.env":ro \
    -v "$(pwd)/build.sh":"/builder/build.sh":ro \
    "openwrt/imagebuilder:$BUILD_TAG" \
        bash
```

- [ap](./ap): 双频，单网口，OpenWrt 默认没有 wan 口、没有 switch
- [router](./router): 双频，主路由，五网口
- [travel](./travel): 双频，三网口
- [onu](./onu): 光猫

---

- https://github.com/mwarning/openwrt-examples/blob/51af905de23df41f6024e81aef14a892e5ef8ef6/README.md#automatic-and-generic-wifi-setup
- https://github.com/astro/nix-openwrt-imagebuilder/
- https://imciel.com/2021/03/20/create-configless-openwrt-firmware/
- https://github.com/ekkog/OpenWrt
- https://vxchin.gitbooks.io/openwrt-fanqiang/content/ebook/04.3.html
- https://hub.docker.com/r/openwrt/imagebuilder/tags
