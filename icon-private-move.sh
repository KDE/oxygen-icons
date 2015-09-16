#!/bin/sh

if [ $# -ne 2 -a $# -ne 3 ]; then
  echo "You need to supply two arguments, e.g.:"
  echo "$0 actions/view-file-columns ../../../../kdebase/apps/dolphin/icons/"
  echo "...and optionally the namespace (e.g. \"ox\" or \"hi\") as third argument."
  exit
fi

# Split the two arguments into their category and icon name parts.
src="$1"
src_category=${src%/*}
src_icon=${src#*/}

destdir="$2"

ns="ox"
if [ $# -eq 3 ]; then
  ns="$3"
fi

svn add $destdir

# Move the scalable icon.
if [ -f scalable/$src.svgz ]; then
  echo "Moving scalable/$src.svgz to $destdir/${ns}sc-$src_category-$src_icon.svgz..."
  svn mv scalable/$src.svgz $destdir/${ns}sc-$src_category-$src_icon.svgz
  echo
fi

# Move the optimized small versions of the icon.
for size in 8 16 22 32 48 64 128 256; do
  dir="${size}x${size}"

  if [ -f scalable/$src_category/small/$dir/$src_icon.svgz ]; then
    echo "Moving scalable/$src_category/small/$dir/$src_icon.svgz"
    echo "    to $destdir/${ns}$size-$src_category-$src_icon.svgz..."

    # Generate the size dir for smaller SVGs (e.g. icons/22x22/) if necessary.
    if [ ! -d $destdir/small ]; then
      svn mkdir $destdir/small
    fi

    svn mv scalable/$src_category/small/$dir/$src_icon.svgz $destdir/small/${ns}$size-$src_category-$src_icon.svgz
    echo
  fi
done

# Move the rendered PNGs.
for size in 8 16 22 32 48 64 128 256; do
  dir="${size}x${size}"

  if [ -f $dir/$src.png ]; then
    echo "Moving $dir/$src.png to $destdir/${ns}$size-$src_category-$src_icon.png..."
    svn mv $dir/$src.png $destdir/${ns}$size-$src_category-$src_icon.png
    echo
  fi
done
