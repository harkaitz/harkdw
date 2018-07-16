#!/bin/sh
#l:
export PATH="`pwd`/bin:$PATH"
## -------------- Generate from templates ----------------------
if test ! -f hrknew.txt;then
    true
elif which hrknew 2>/dev/null >/dev/null;then
    hrknew -a
else
    echo "(*) Skipping regenerating from templates ..."
fi
## -------------- Generate README.md from README.md.in ---------
if test ! -f README.md.in;then
    true
elif which hrkreadme 2>/dev/null >/dev/null;then
    echo "Generating new readme from README.md.in ..."
    hrkreadme -o README.md README.md.in || echo "New README.md not generated."
else
    echo "(*) Skipping regenerating README.md ..."
fi
## -------------- Print file licenses --------------------------
if ! which hrklicense 2>/dev/null >/dev/null;then
    true
elif ! hrklicense -s 2>/dev/null;then
    echo "No license found, creating \`LICENSE.txt\` (MIT)..."
    hrklicense -p mit.txt > /tmp/LICENSE.txt.tmp
    mv /tmp/LICENSE.txt.tmp LICENSE.txt
    hrklicense -cl
else
    hrklicense -cl
fi
