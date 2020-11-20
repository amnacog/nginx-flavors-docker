## Build phase
FROM alpine:3.12 as build


#ARG FLAVOR=nginx:1.19.4
# OR
ARG FLAVOR=openresty:1.19.3.1
ARG PERLVERSION=5.32.0
ARG LUAVERSION=5.3.5
ARG LUAROCKSVERSION=3.4.0
ARG OPMVERSION=0.0.5


ARG NGX_FLAGS="\
--prefix=/var/lib/nginx,\
--sbin-path=/usr/sbin/nginx,\
--modules-path=/usr/lib/nginx/modules,\
--conf-path=/etc/nginx/nginx.conf,\
--pid-path=/run/nginx/nginx.pid,\
--lock-path=/run/nginx/nginx.lock,\
--http-client-body-temp-path=/var/lib/nginx/tmp/client_body,\
--http-proxy-temp-path=/var/lib/nginx/tmp/proxy,\
--http-fastcgi-temp-path=/var/lib/nginx/tmp/fastcgi,\
--http-uwsgi-temp-path=/var/lib/nginx/tmp/uwsgi,\
--http-scgi-temp-path=/var/lib/nginx/tmp/scgi,\
--with-perl_modules_path=/usr/lib/perl5/vendor_perl,\
--user=nginx,\
--group=nginx"

ARG NGX_FEATURES="\
compat,\
threads,\
file-aio,\
pcre-jit,\
ipv6,\
http_ssl_module,\
http_v2_module,\
http_realip_module,\
http_addition_module,\
http_sub_module,\
http_dav_module,\
http_flv_module,\
http_mp4_module,\
http_gunzip_module,\
http_gzip_static_module,\
http_auth_request_module,\
http_random_index_module,\
http_secure_link_module,\
http_degradation_module,\
http_slice_module,\
http_stub_status_module,\
mail_ssl_module,\
stream_ssl_preread_module,\
stream_ssl_module,\
stream_realip_module,\
stream_geoip_module=dynamic,\
http_xslt_module=dynamic,\
http_image_filter_module=dynamic,\
http_geoip_module=dynamic,\
http_perl_module=dynamic,\
mail=dynamic,\
stream=dynamic"

ARG NGX_MODS_DEPS="\
https://github.com/maxmind/libmaxminddb:1.4.3;./bootstrap && ./configure && make -j$(nproc) && make install,\
https://github.com/spiderlabs/modsecurity:v3.0.4;./build.sh && ./configure && make -j$(nproc) && make install,\
https://github.com/LuaJIT/LuaJIT:v2.0.5"


ARG NGX_MODS=

ARG LUAROCKS_MODS=

ADD mods.txt build-scripts/ /tmp/scripts/

RUN /tmp/scripts/deps.sh add \
    curl \
    git \
    make \
    gcc \
    g++ \
    autoconf \
    automake \
    musl-dev \
    readline-dev \
    linux-headers \
    libtool \
    libaio-dev \
    pcre-dev \
    openssl-dev \
    zlib-dev \
    libxslt-dev \
    libxml2 \
    gd-dev \
    geoip-dev \
    perl \
    perl-dev

RUN /tmp/scripts/build-base.sh


## Configuration phase

# FROM lsiobase/alpine:version-e4b17fd2

# COPY --from=build /etc/nginx             /etc
# COPY --from=build /usr/lib/nginx         /usr/lib
# COPY --from=build /usr/local/bin         /usr/local/bin
# COPY --from=build /usr/local/include     /usr/local/include
# COPY --from=build /usr/local/lib         /usr/local/lib
# COPY --from=build /usr/local/etc         /usr/local/etc
# COPY --from=build /usr/local/share       /usr/local/share
