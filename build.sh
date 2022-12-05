#!/bin/bash

echo
echo "--------------------------------------"
echo "      Evolution X 13.0 Buildbot       "
echo "                  by                  "
echo "                ponces                "
echo "--------------------------------------"
echo

set -e

BL=$PWD/treble_build_evo
BD=/tmp/itzkaguya/builds

initRepos() {
    if [ ! -d .repo ]; then
        echo "--> Initializing workspace"
        repo init -u https://github.com/Evolution-X/manifest -b tiramisu
        echo

        echo "--> Preparing local manifest"
        mkdir -p .repo/local_manifests
        cp $BL/manifest.xml .repo/local_manifests/evo.xml
        echo
    fi
}

syncRepos() {
    echo "--> Syncing repos"
    repo sync -c --force-sync --no-clone-bundle --no-tags -j$(nproc --all)
    echo
}

applyPatches() {
    echo "--> Applying prerequisite patches"
    bash $BL/apply-patches.sh $BL prerequisite
    echo

    echo "--> Applying TrebleDroid patches"
    cd device/phh/treble
    cp $BL/evo.mk .
    bash generate.sh evo
    cd ../../..
    bash $BL/apply-patches.sh $BL trebledroid
    echo

    echo "--> Applying personal patches"
    bash $BL/apply-patches.sh $BL personal
    echo
}

setupEnv() {
    echo "--> Setting up build environment"
    source build/envsetup.sh &>/dev/null
    mkdir -p $BD
    echo
}

buildTrebleApp() {
    echo "--> Building treble_app"
    cd treble_app
    bash build.sh release
    cp TrebleApp.apk ../vendor/hardware_overlay/TrebleApp/app.apk
    cd ..
    echo
}

buildVariant() {
    echo "--> Building treble_a64_bvN"
    lunch treble_a64_bvN-userdebug
    make -j$(nproc --all) installclean
    make -j$(nproc --all) systemimage
    mv $OUT/system.img $BD/system-treble_a64_bvN.img
    echo
}

buildVndkliteVariant() {
    echo "--> Building treble_a64_bvN-vndklite"
    cd sas-creator
    sudo bash lite-adapter.sh 64 $BD/system-treble_a64_bvN.img
    cp s.img $BD/system-treble_a64_bvN-vndklite.img
    sudo rm -rf s.img d tmp
    cd ..
    echo
}

generatePackages() {
    echo "--> Generating packages"
    xz -cv $BD/system-treble_a64_bvN.img -T0 > $BD/evolution_a64-ab-7.3-ItzKaguya.img.xz
    xz -cv $BD/system-treble_a64_bvN-vndklite.img -T0 > $BD/evolution_a64-ab-vndklite-7.3-ItzKaguya.img.xz
    rm -rf $BD/system-*.img
    echo
}

START=`date +%s`
BUILD_DATE="$(date +%Y%m%d)"

initRepos
syncRepos
applyPatches
setupEnv
buildTrebleApp
buildVariant
buildVndkliteVariant
generatePackages

END=`date +%s`
ELAPSEDM=$(($(($END-$START))/60))
ELAPSEDS=$(($(($END-$START))-$ELAPSEDM*60))

echo "--> Buildbot completed in $ELAPSEDM minutes and $ELAPSEDS seconds"
echo
