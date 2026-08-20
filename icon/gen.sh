for i in 16 32 64 128 256 512; do convert -resize ${i}x${i} ring.png icon-$i.png; done
