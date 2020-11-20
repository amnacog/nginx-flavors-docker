#!/usr/bin/env sh

set -e
OIFS="$IFS"

cd $(dirname $0)
for f in ./includes.d/*.sh; do . $f; done

os=$(uname | tr '[:upper:]' '[:lower:]')
flags=""
mods=""


baseType=$(echo $FLAVOR | cut -d: -f1)
baseVersion=$(echo $FLAVOR | cut -d: -f2)
baseSourcePath="/tmp/base-source-${baseType}"

perlVersion=$PERLVERSION
perlSourcePath="/tmp/perl"

luaVersion=$LUAVERSION
luaSourcePath="/tmp/lua"

luarocksVersion=$LUAROCKSVERSION
luarocksSourcePath="/tmp/luarocks"

opmVersion=$OPMVERSION
opmSourcePath="/tmp/opm"

git config --global advice.detachedHead false

if ! (echo $baseType | grep -q 'nginx\|openresty'); then
    echo "[Error] Invalid build base selected: $baseType" 2>&1
    exit 1
fi

## Prepare Modules

IFS=,; for flag in $NGX_FLAGS; do
    flags="$flags $flag"
done
for feature in $NGX_FEATURES; do
    flags="$flags --with-${feature}"
done; IFS="$OIFS"

modsPath="/tmp/modules"
mkdir -p $modsPath
modFile=$(cat /tmp/scripts/mods.txt | grep -v '#' | awk 'NF' | tr '\n' ',')

IFS=,; for source in ${modFile%?}${NGX_MODS}; do
    sourceUrl=$(echo $source | cut -d';' -f1)
    depName=$(echo $sourceUrl |rev| cut -d'/' -f1 | rev | cut -d':' -f1)
    mods="$mods --add-dynamic-module=$modsPath/$depName"
    Clone $sourceUrl $modsPath
    [ $(echo $source | awk -F';' '{print NF-1}') -gt 0 ] && extraArgs=$(echo $source | cut -d';' -f2-)
    [ -z "$extraArgs" ] || ( cd "$modsPath/$depName"; eval "$extraArgs"; cd - &>/dev/null )
    unset extraArgs
done

modsDepsPath="/tmp/modulesDeps"
mkdir -p $modsDepsPath
for source in ${NGX_MODS_DEPS}; do
    sourceUrl=$(echo $source | cut -d';' -f1)
    [ $(echo $source | awk -F';' '{print NF-1}') -gt 0 ] && extraArgs=$(echo $source | cut -d';' -f2-)
    depName=$(echo $sourceUrl |rev| cut -d'/' -f1 | rev | cut -d':' -f1)
    Clone $sourceUrl $modsDepsPath
    BaseInstall "$modsDepsPath/$depName" "$extraArgs"
    unset extraArgs
done; IFS="$OIFS"

## Prepare prerequisites

if [ "$baseType" == "openresty" ]; then
    Down2file "http://www.lua.org/ftp/lua-" $luaVersion ".tar.gz" $luaSourcePath
    Down2file "https://openresty.org/download/openresty-" $baseVersion ".tar.gz" $baseSourcePath
    Down2file "https://luarocks.github.io/luarocks/releases/luarocks-" $luarocksVersion ".tar.gz" $luarocksSourcePath
    #Down2file "https://github.com/openresty/opm/archive/v" $opmVersion ".tar.gz" $opmSourcePath
    
    BaseInstall $luaSourcePath "make linux && make install"
    BaseInstall $luarocksSourcePath
    #BaseInstall $opmSourcePath

    # remove extra embedded modules
    whitelistMods="http_ssl_module,stream_ssl_module,ngx_devel_kit_module,http_lua_module"
    flags="$flags $(cd $baseSourcePath;./configure --help | sed -n "1,/inherited from nginx/p" | grep -v "${whitelistMods//,/\\|}" | grep 'without.*_module' | awk '{print $1}' | xargs;cd - >/dev/null)"
    
    BaseInstall $baseSourcePath "./configure -j$(nproc) ${NGX_FLAGS//,/ } $flags $mods && make -j$(nproc) && make install"
elif [ "$baseType" == "nginx" ]; then
    Down2file "https://github.com/nginx/nginx/archive/release-" $baseVersion ".tar.gz" $baseSourcePath
    BaseInstall $baseSourcePath "./auto/configure ${NGX_FLAGS//,/ } $flags $mods && make -j$(nproc) && make install"
fi