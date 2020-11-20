function BaseInstall () {
    echo "[Info] Building $(basename $1)"
    cd $1
    (
        [ -f configure ] && sh configure $2
        [ -f Configure ] && sh Configure $2
        make $3
        make install
    )
} 