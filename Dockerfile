FROM openresty/openresty:alpine-fat AS production-stage
ADD patch.sh .
RUN set -x \
    && /bin/sed -i 's,http://dl-cdn.alpinelinux.org,https://mirrors.aliyun.com,g' /etc/apk/repositories \
    && apk add --no-cache --virtual .builddeps \
    automake \
    autoconf \
    libtool \
    pkgconfig \
    cmake \
    git \
    bash \
    libstdc++ \
    curl \
    && luarocks install https://github.com/apache/incubator-apisix/raw/master/rockspec/apisix-master-0.rockspec --tree=/usr/local/apisix/deps \
    && cp -v /usr/local/apisix/deps/lib/luarocks/rocks-5.1/apisix/master-0/bin/apisix /usr/bin/ \
    && bin='#! /usr/local/openresty/luajit/bin/luajit\npackage.path = "/usr/local/apisix/?.lua;/usr/local/apisix/addons/?.lua;/usr/local/apisix/addons/deps/share/lua/5.1/?.lua;" .. package.path\npackage.cpath = "/usr/local/apisix/addons/deps/lib64/lua/5.1/?.so;/usr/local/apisix/addons/deps/lib/lua/5.1/?.so;" .. package.cpath' \
    && sed -i "1s@.*@$bin@" /usr/bin/apisix \
    && mv /usr/local/apisix/deps/share/lua/5.1/apisix /usr/local/apisix \
    && sh ./patch.sh \
    && mkdir /usr/local/apisix/addons \
    && apk del .builddeps build-base make unzip

WORKDIR /usr/local/apisix

ADD dashboard.tar.gz /usr/local/apisix

ENV PATH=$PATH:/usr/local/openresty/luajit/bin:/usr/local/openresty/nginx/sbin:/usr/local/openresty/bin

EXPOSE 9080 9443

CMD ["sh", "-c", "/usr/bin/apisix init && /usr/bin/apisix init_etcd && /usr/local/openresty/bin/openresty -p /usr/local/apisix -g 'daemon off;'"]

STOPSIGNAL SIGQUIT