# 基于openresty/openresty:centos

FROM openresty/openresty:centos AS production-stage

RUN set -x \
    && yum -y install \
    which \
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
    && sed -i "1s@.*@#!/usr/local/openresty/luajit/bin/luajit@" /usr/bin/apisix \
    && mv /usr/local/apisix/deps/share/lua/5.1/apisix /usr/local/apisix

FROM openresty/openresty:centos  as last-stage

WORKDIR /usr/local/apisix

COPY --from=production-stage /usr/local/openresty/ /usr/local/openresty/
COPY --from=production-stage /usr/local/apisix/ /usr/local/apisix/
COPY --from=production-stage /usr/bin/apisix /usr/bin/apisix

ADD dashboard.tar.gz .

ENV PATH=$PATH:/usr/local/openresty/luajit/bin:/usr/local/openresty/nginx/sbin:/usr/local/openresty/bin


EXPOSE 9080 9443
VOLUME ["/usr/local/apisix/addons"]

ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD [""]

STOPSIGNAL SIGQUIT
