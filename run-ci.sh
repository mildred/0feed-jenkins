#!/bin/bash

title(){
  local tmpl="$1"
  shift
  printf "\e[1;37m==> $tmpl\e[0m\n" "$@"
}

set -e

# TODO: feed=$(0compile info compile.interface)
feed="$(python3 <<EOF
import configparser
c=configparser.ConfigParser()
c.read("0compile.properties")
print(c["compile"]["interface"])
EOF
)"

title "Build using feed %s" "$feed"

if [ -e gh-pages/$feed ]; then
  mv gh-pages/$feed $feed.old;
  cp "$feed" "gh-pages/$feed";
  # TODO: report old interfaces to new feed
  # TODO: 0publish --ignore-duplicates -a "$feed.old" "gh-pages/$feed"
else
  touch $feed.old;
  cp "$feed" "gh-pages/$feed";
fi


if [ -d 0compile.version/ ]; then
  version=$( (cd 0compile.version && git describe --tags --dirty --always | sed "s/^[^0-9]*//") );
elif [ -x 0compile.version ]; then
  title "Run 0compile.version"
  version=$(./0compile.version);
elif [ -e 0compile.version ]; then
  version=$(cat 0compile.version);
else
  version=$(git describe --tags --dirty --always | sed "s/^[^0-9]*//");
fi

title "Build version is %s" "$version"

if [ -n "$version" ]; then
  # TODO: 0publish --set-version=$version --select-source $feed
  0publish --set-version=$version --select-version=0 $feed;
fi

if [ -x 0compile.sh ]; then
  title "Run 0compile.sh"
  eval "$(./0compile.sh)";
  archive="$(sed -n -e 's/.*<archive.*href=["'"'"']\([^"'"'"']*\)["'"'"'].*/\1/p' "$new_feed")";
else
  title "Run 0compile build"
  0compile build;
  uri="$(sed -n -e 's/.*uri=["'"'"']\([^"'"'"']*\)["'"'"'].*/\1/p' "$feed" | head -n 1)";
  pub="$(0compile publish "${uri%/*}/")";
  # TODO: detect uri basename
  # TODO: allow to set version
  # TODO: 0compile publish --target-file=$feed.new --set-version="$version" --out-dir="gh-pages"
  echo "$pub";
  archive="$(echo "$pub" | sed -n '2 p')";
  new_feed="$(echo "$pub" | sed -n 's/^\$ 0launch //p')";
fi

if [ -e "gh-pages/$(basename "$archive")" ]; then
  title "Artifact %s already exists, cancel build" "$(basename "$archive")"
  exit 0
fi

title "Copy %s" "$(basename "$archive")"
cp "$(basename "$archive")" gh-pages

title "Prepare and sign feed %s" "$feed"
sed -i '/<implementation .*version=["'"'"']'"$version"'["'"'"']/,/<\/implementation>/ d' "gh-pages/$feed"
sed -i '/^<!-- Base64 Signature/,/^-->/ d' "gh-pages/$feed"
0publish -a "${new_feed}" "gh-pages/$feed"
#- 0publish --xmlsign -k $GPG_KEY_ID "gh-pages/$feed"
gpg --passphrase-file passphrase --batch --default-key $GPG_KEY_ID --sign --detach-sign --output "gh-pages/$feed.sig" "gh-pages/$feed"
printf "<!-- Base64 Signature\n%s\n-->\n" $(base64 -w0 <"gh-pages/$feed.sig") >> "gh-pages/$feed"
gpg --passphrase-file passphrase --batch --armor --output gh-pages/$GPG_KEY_ID.gpg --export $GPG_KEY_ID || true
cat gh-pages/$feed >$feed.new
diff -u $feed.old $feed.new || true

title "Commit release"
(cd gh-pages && git add "$(basename "$archive")")
(cd gh-pages && git add "$feed" "$GPG_KEY_ID.gpg")
(cd gh-pages && git commit -m "Release $version" || true)
