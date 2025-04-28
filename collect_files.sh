#!/bin/bash

maxdepth=""
src=""
dst=""

for arg in "$@"; do
    if [ "$arg" = "--max_depth" ]; then
        maxdepth="$2"
        shift 2
    else
        if [ -z "$src" ]; then
            src="$arg"
        else
            dst="$arg"
        fi
        shift
    fi
done

if [ -z "$src" ] || [ -z "$dst" ]; then
    echo "Usage: $0 [--max_depth <depth>] <input_dir> <output_dir>"
    exit 1
fi
if [ ! -d "$src" ]; then
    echo "Ошибка: '$src' не является директорией"
    exit 1
fi
mkdir -p "$dst" || {
    echo "Ошибка: Невозможно создать директорию '$dst'"
    exit 1
}

main() {
    filepath="$1"
    outdir="$2"
    fname=$(basename "$filepath")
    base="${fname%.*}"
    ext="${fname##*.}"
    idx=1
    newfile="$fname"

    if [ "$fname" = "$ext" ]; then
        ext=""
    else
        ext=".$ext"
    fi

    while [ -f "$outdir/$newfile" ]; do
        newfile="${base}${idx}${ext}"
        ((idx++))
    done

    echo "$newfile"
}

if [ -n "$maxdepth" ]; then
    depth="-maxdepth $maxdepth"
else
    depth=""
fi

for file in $(find "$src" -type f $depth); do
    newname=$(main "$file" "$dst")
    cp -v "$file" "$dst/$newname" || {
        echo "Ошибка: Невозможно скопировать файл $file в $dst/$newname"
        exit 1
    }
done
exit 0