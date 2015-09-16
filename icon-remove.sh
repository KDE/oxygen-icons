#!/bin/sh

if [ $# -ne 1 ]; then
  echo "You need to supply exactly one argument, e.g.:"
  echo "$0 actions/contents2"
  exit
fi

# Split the two arguments into their category and icon name parts.
src="$1"
src_category=${src%/*}
src_icon=${src#*/}

# Remove the scalable icon.
if [ -f scalable/$src.svgz ]; then
  echo "Removing scalable/$src.svgz..."
  svn rm scalable/$src.svgz
  echo
fi

# Remove the optimized small versions of the icon.
for dir in 8x8 16x16 22x22 32x32 48x48 64x64 128x128 256x256; do
  if [ -f scalable/$src_category/small/$dir/$src_icon.svgz ]; then
    echo "Removing scalable/$src_category/small/$dir/$src_icon.svgz..."
    svn rm scalable/$src_category/small/$dir/$src_icon.svgz
    echo
  fi
done

# Remove the rendered PNGs.
for dir in 8x8 16x16 22x22 32x32 48x48 64x64 128x128 256x256; do
  if [ -f $dir/$src.png ]; then
    echo "Removing $dir/$src.png..."
    svn rm $dir/$src.png
    echo
  fi
done
