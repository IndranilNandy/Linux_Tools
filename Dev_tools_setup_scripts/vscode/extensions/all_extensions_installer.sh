#!/bin/bash
if [[ -L $(which code-ext) ]]; then
    curDir="$(dirname "$(tracelink code-ext)")"
else
    curDir="$(pwd)/extensions"
fi

cat $curDir/.extensions | xargs -n1 code --install-extension