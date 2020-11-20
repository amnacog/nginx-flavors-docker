function Clone() {
    mod=$1
    repoUrl=$(echo $mod | cut -d':' -f1-2)
    name=$(echo $repoUrl |rev| cut -d'/' -f1 |rev)
    tag=$(echo $mod | cut -d':' -f3)

    pathInstall=${2:-.}
    savepwd=$(pwd)

    (
        set -e
        echo "[Info] Cloning ${name} into ${pathInstall}..."
        git clone -q $repoUrl "$pathInstall/$name"
        cd "$pathInstall/$name"
        git fetch --tags
        [ -z "$tag" ] || git checkout -q $tag
        git submodule update -q --init --recursive
        cd $pwd
        set +e
    )
}