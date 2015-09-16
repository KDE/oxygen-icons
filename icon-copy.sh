#!/bin/sh

if [ $# -ne 2 ]; then
  echo "You need to supply two arguments, e.g.:"
  echo "$0 mimetypes/text-plain mimetypes/text-x-generic"
  exit
fi

# Split the two arguments into their category and icon name parts.
src="$1"
src_category=${src%/*}
src_icon=${src#*/}

dest="$2"
dest_category=${dest%/*}
dest_icon=${dest#*/}

# Copy the scalable icon.
if [ -f scalable/$src.svgz ]; then
  echo "Copying scalable/$src.svgz to scalable/$dest.svgz..."
  svn cp scalable/$src.svgz scalable/$dest.svgz
  echo
fi

# Copy the optimized small versions of the icon.
for dir in 8x8 16x16 22x22 32x32 48x48 64x64 128x128 256x256; do
  if [ -f scalable/$src_category/small/$dir/$src_icon.svgz ]; then
    echo "Copying scalable/$src_category/small/$dir/$src_icon.svgz"
    echo "     to scalable/$dest_category/small/$dir/$dest_icon.svgz..."
    svn cp scalable/$src_category/small/$dir/$src_icon.svgz scalable/$dest_category/small/$dir/$dest_icon.svgz
    echo
  fi
done

# Copy the rendered PNGs.
for dir in 8x8 16x16 22x22 32x32 48x48 64x64 128x128 256x256; do
  if [ -f $dir/$src.png ]; then
    echo "Copying $dir/$src.png to $dir/$dest.png..."
    svn cp $dir/$src.png $dir/$dest.png
    echo
  fi
done
