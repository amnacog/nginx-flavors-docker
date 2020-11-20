## Build phase
FROM alpine:3.12 as build


#ARG FLAVOR=nginx:1.19.4
# OR
ARG FLAVOR=openresty:1.19.3.1
ARG PERLVERSION=5.32.0
ARG LUAVERSION=5.3.5
ARG LUAROCKSVERSION=3.4.0
ARG OPMVERSION=0.0.5

ARG STATICMODS=\
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
stream=dynamic

ARG DYNAMICMODS=

ARG LUAROCKSMODS=

ADD mods.txt build-scripts/ /tmp/scripts/

RUN /tmp/scripts/deps.sh add \
    curl \
    git \
    make \
    gcc \
    musl-dev \
    readline-dev \
    perl

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
