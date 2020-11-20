function defaultInstallSet () {
    [ -f configure ] && ./configure 
    [ -f Configure ] && ./Configure
    make -j$(nproc)
    make install
}

function BaseInstall () {
    echo "[Info] Building $(basename $1) (this may take a while)"
    echo $2
    (
        cd $1
        [ -z "$2" ] && defaultInstallSet || eval "$2"
        cd - &>/dev/null
    )
}