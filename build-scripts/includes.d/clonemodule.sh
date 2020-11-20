function CloneMod() {
    mod=$1
    repoUrl=$(echo $mod | cut -d':' -f1-2)
    name=$(echo $repoUrl |rev| cut -d'/' -f1 |rev)
    tag=$(echo $mod | cut -d':' -f3)

    (
        set -e
        echo "[Info] Cloning module ${name}..."
        git clone $repoUrl
        cd $name
        git fetch --tags
        [ -z "$tag" ] || git checkout $tag
        git submodule update --init --recursive
        cd ..
        set +e
    ) 2>/dev/null
}