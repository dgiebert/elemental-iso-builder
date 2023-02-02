#!/bin/sh

src="output/tmp/"
dest="output/"
iso="elemental-teal.arm64.iso"

rm -f "${dest}${iso}"
rm -f "${dest}${iso}.sha256"

[ -f "${src}${iso}" ] || exit 1

cp "${src}${iso}" ${dest}
cp "${src}${iso}.sha256" ${dest}