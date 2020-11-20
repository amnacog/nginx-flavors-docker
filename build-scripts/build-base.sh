#!/usr/bin/env sh

set -e
OIFS="$IFS"

cd $(dirname $0)
for f in ./includes.d/*.sh; do . $f; done

os=$(uname | tr '[:upper:]' '[:lower:]')

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

if ! (echo $baseType | grep -q 'nginx\|openresty'); then
    echo "[Error] Invalid build base selected: $baseType" 2>&1
    exit 1
fi

## Prepare prerequisites

if [ "$baseType" == "openresty" ]; then
    Down2file "http://www.lua.org/ftp/lua-" $luaVersion ".tar.gz" $luaSourcePath
    Down2file "https://openresty.org/download/openresty-" $baseVersion ".tar.gz" $baseSourcePath
    Down2file "https://luarocks.github.io/luarocks/releases/luarocks-" $luarocksVersion ".tar.gz" $luarocksSourcePath
    # Down2file "https://github.com/openresty/opm/archive/v" $opmVersion ".tar.gz" $opmSourcePath
    
    BaseInstall $luaSourcePath "" linux
    BaseInstall $luarocksSourcePath
    # BaseInstall $opmSourcePath

elif [ "$baseType" == "nginx" ]; then
    Down2file "https://github.com/nginx/nginx/archive/release-" $baseVersion ".tar.gz" $baseSourcePath
fi

## Prepare Modules

staticMods="";
IFS=,; for mod in $STATICMODS; do
    staticMods="$staticMods --with-${module}"
done; IFS="$OIFS"

dynamicMods="";
dynamicModsPath="/tmp/modules"
mkdir -p $dynamicModsPath
cd $dynamicModsPath
modFile=$(cat /tmp/scripts/mods.txt | grep -v '#' | awk 'NF' | tr '\n' ',')

IFS=,; for mod in ${modFile%?}${DYNAMICMODS}; do
    dynamicMods="$dynamicMods --add-dynamic-module=$dynamicModsPath/$(echo $repoUrl |rev| cut -d'/' -f1 |rev)"
    CloneMod $mod
done;  IFS="$OIFS"
cd $(dirname $0)


echo $staticMods $dynamicMods