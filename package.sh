#!/usr/bin/env bash

readonly target=${1:?Please provide build target: \"ankiweb\" or \"github\"}
readonly addon_name="Paste Images As WebP"
readonly package_filename="${addon_name// /}.ankiaddon"
readonly support_dir="support"
readonly manifest=manifest.json

readonly webp_windows="https://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-1.1.0-windows-x64.zip"
readonly webp_linux="https://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-1.1.0-linux-x86-64.tar.gz"

rm -- "$package_filename" 2>/dev/null

if [[ "$target" != 'ankiweb' ]]; then
    # https://addon-docs.ankiweb.net/#/sharing?id=sharing-outside-ankiweb
    # If you wish to distribute .ankiaddon files outside of AnkiWeb,
    # your add-on folder needs to contain a ‘manifest.json’ file.
    {
        echo '{'
        echo -e "\t\"package\": \"${package_filename%.*}\","
        echo -e "\t\"name\": \"$addon_name\","
        echo -e "\t\"mod\": $(date -u '+%s')"
        echo '}'
    } > $manifest
fi

if ! [[ -f ./$support_dir/cwebp && -f ./$support_dir/cwebp.exe ]]; then
	readonly tmp_dir=./$support_dir/temp/
	mkdir -p -- $tmp_dir
	for url in "$webp_windows" "$webp_linux"; do
		filename=${url##*/}
		if [[ ! -f $tmp_dir/$filename ]]; then
			curl --output $tmp_dir/$filename -- "$url"
		fi
		atool -f -X $tmp_dir/ -- $tmp_dir/$filename
	done
	find $tmp_dir -type f  \( -name 'cwebp' -o -name 'cwebp.exe' \) -exec mv -- {} ./$support_dir/ \;
	rm -rf $tmp_dir
fi

zip -r "$package_filename" \
	./*.py \
	./utils/*.py \
	./$manifest \
	./config.* \
	./icons/* \
	./$support_dir \

rm -- $manifest 2>/dev/null
