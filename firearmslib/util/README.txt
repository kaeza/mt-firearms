
This directory contains utilities meant for developers. If you don't intend
to contribute patches to firearmslib, then these files may not be interesting
to you. The only file that may be of interest for end users is the example
configuration file `firearms.conf.example' (and maybe the `player_setfov.patch'
file).

extract-images.sh
  This script uses the `convert' program from ImageMagick to split the
  `firearms.png' image file into the different textures.

findtodo.sh
  Utility script for IDEs to find "TO-DO" items.

firearms.conf.example
  Example configuration file for firearms modpack.

firearms.png
  Most of the textures of the modpack as a big image. I find it easier to
  modify a single big file and then split it than editing many smaller files.

player_setfov.patch
  Patch for Minetest to allow per-player FOV modification at runtime. Please
  note that the patch may be outdated and may not apply correctly under the
  current Minetest source tree. Use at your own risk.

README.txt
  This file.
