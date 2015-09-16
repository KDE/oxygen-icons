#!/bin/sh

if [ $# -ne 2 ]; then
  echo "You need to supply two arguments, e.g.:"
  echo "$0 actions/ark_extract actions/archive-extract"
  exit
fi

# Split the two arguments into their category and icon name parts.
src="$1"
src_category=${src%/*}
src_icon=${src#*/}

dest="$2"
dest_category=${dest%/*}
dest_icon=${dest#*/}

# Move the scalable icon.
if [ -f scalable/$src.svgz ]; then
  echo "Moving scalable/$src.svgz to scalable/$dest.svgz..."
  svn mv scalable/$src.svgz scalable/$dest.svgz
  echo
fi

# Move the optimized small versions of the icon.
for dir in 8x8 16x16 22x22 32x32 48x48 64x64 128x128 256x256; do
  if [ -f scalable/$src_category/small/$dir/$src_icon.svgz ]; then
    echo "Moving scalable/$src_category/small/$dir/$src_icon.svgz"
    echo "    to scalable/$dest_category/small/$dir/$dest_icon.svgz..."
    svn mv scalable/$src_category/small/$dir/$src_icon.svgz scalable/$dest_category/small/$dir/$dest_icon.svgz
    echo
  fi
done

# Move the rendered PNGs.
for dir in 8x8 16x16 22x22 32x32 48x48 64x64 128x128 256x256; do
  if [ -f $dir/$src.png ]; then
    echo "Moving $dir/$src.png to $dir/$dest.png..."
    svn mv $dir/$src.png $dir/$dest.png
    echo
  fi
done
