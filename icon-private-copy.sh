#!/bin/sh

if [ $# -ne 3 -a $# -ne 4 ]; then
  echo "You need to supply three mandatory arguments, e.g.:"
  echo "$0 apps/internet-mail apps/kmail ../../../../kdepim/kmail/icons/"
  echo "...and optionally the namespace (e.g. \"ox\" or \"hi\") as fourth argument."
  exit
fi

# Split the two arguments into their category and icon name parts.
src="$1"
src_category=${src%/*}
src_icon=${src#*/}

dest="$2"
dest_category=${dest%/*}
dest_icon=${dest#*/}

destdir="$3"

ns="ox"
if [ $# -eq 4 ]; then
  ns="$4"
fi

svn add $destdir

# Copy the scalable icon.
if [ -f scalable/$src.svgz ]; then
  echo "Copying scalable/$src.svgz to $destdir/${ns}sc-$dest_category-$dest_icon.svgz..."
  svn cp scalable/$src.svgz $destdir/${ns}sc-$dest_category-$dest_icon.svgz
  echo
fi

# Copy the optimized small versions of the icon.
for size in 8 16 22 32 48 64 128 256; do
  dir="${size}x${size}"

  if [ -f scalable/$src_category/small/$dir/$src_icon.svgz ]; then
    echo "Copying scalable/$src_category/small/$dir/$src_icon.svgz"
    echo "     to $destdir/${ns}$size-$dest_category-$dest_icon.svgz..."

    # Generate the size dir for smaller SVGs (e.g. icons/22x22/) if necessary.
    if [ ! -d $destdir/small ]; then
      svn mkdir $destdir/small
    fi

    svn cp scalable/$src_category/small/$dir/$src_icon.svgz $destdir/small/${ns}$size-$dest_category-$dest_icon.svgz
    echo
  fi
done

# Copy the rendered PNGs.
for size in 8 16 22 32 48 64 128 256; do
  dir="${size}x${size}"

  if [ -f $dir/$src.png ]; then
    echo "Copying $dir/$src.png to $destdir/${ns}$size-$dest_category-$dest_icon.png..."
    svn cp $dir/$src.png $destdir/${ns}$size-$dest_category-$dest_icon.png
    echo
  fi
done
