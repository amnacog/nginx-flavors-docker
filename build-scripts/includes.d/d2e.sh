set -e
function Down2file () {
    sourceUrl=$1
    version=$2
    fileType=$3
    downloadPath=$4
    name=$(basename $downloadPath)

    fileEndpoint="${sourceUrl}${version}${fileType}"

    echo "[Info] Downloading ${name}:${version}..."

    httpCode=$(/usr/bin/curl -L --silent --fail $fileEndpoint --write-out "%{http_code}" --output "${downloadPath}${fileType}")
    if [ $? -eq 22 ]; then
        echo "[Error] Failed to download ${name}: $fileEndpoint [$httpCode]" >&2
        exit 22
    fi

    /bin/mkdir -p $downloadPath
    /bin/tar -xzf "${downloadPath}${fileType}" -C $downloadPath
    /bin/mv $downloadPath/*/* $downloadPath/*/.* $downloadPath 2>/dev/null || true
    /bin/rmdir $downloadPath/* 2>/dev/null || true
}