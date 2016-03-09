#! /bin/bash

convert -geometry 16x16     ./Icon.png ./icon_16x16.png
convert -geometry 32x32     ./Icon.png ./icon_16x16@2x.png
convert -geometry 32x32     ./Icon.png ./icon_32x32.png
convert -geometry 64x64     ./Icon.png ./icon_32x32@2x.png
convert -geometry 128x128   ./Icon.png ./icon_128x128.png
convert -geometry 256x256   ./Icon.png ./icon_128x128@2x.png
convert -geometry 256x256   ./Icon.png ./icon_256x256.png
convert -geometry 512x512   ./Icon.png ./icon_256x256@2x.png
convert -geometry 512x512   ./Icon.png ./icon_512x512.png
convert -geometry 1024x1024 ./Icon.png ./icon_512x512@2x.png
