#! /bin/bash
cd "$(dirname "$0")/../..";
# String is split here to avoid matching itself.
exec grep 'TO''DO' -RHn . #| less;
