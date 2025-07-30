#!/bin/bash
kitty
if [ $? -ne 0 ]; then
    env LIBGL_ALWAYS_SOFTWARE=true GALLIUM_DRIVER=llvmpipe kitty
    if [ $? -ne 0 ]; then
        konsole
    fi
fi
