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
  #mv gh-pages/$feed $feed.old;
  cp "$feed" "gh-pages/$feed";
  # TODO: report old interfaces to new feed
  # TODO: 0publish --ignore-duplicates -a "$feed.old" "gh-pages/$feed"
else
  touch $feed.old;
  cp "$feed" "gh-pages/$feed";
fi


url=http://mirrors.jenkins.io/war/
version="$(lftp -c "open $url; cls" | sed -n 's:^\([0-9\.]*\)/$:\1:p' | sort -V | tail -n 1)"
lftp -c "get $url/$version/jenkins.war" >&2

title "Build version is %s" "$version"

if [ -n "$version" ]; then
  0publish --set-version=$version $feed;
fi

new_feed=jenkins-$version.xml
0template -o $new_feed jenkins.xml.template version=$version

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

exit 0

title "Commit release"
(cd gh-pages && git add "$(basename "$archive")")
(cd gh-pages && git add "$feed" "$GPG_KEY_ID.gpg")
(cd gh-pages && git commit -m "Release $version" || true)
