#!/bin/sh

function flash()
{
    echo "Flasing $1 using $2"
    fastboot flash $1 $2 && return
    echo "Failed at flashing $1 using $2"
    exit 1
}

flash tlk lk.bin
flash lk_data lk_data_boombox.img
flash boot boot.img
flash recovery recovery.img
flash cache cache.img
flash data userdata.img
flash system system.img

echo "Completed"
