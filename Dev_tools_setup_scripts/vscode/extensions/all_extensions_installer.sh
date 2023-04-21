#!/bin/bash
if [[ -L $(which code-ext) ]]; then
    curDir="$(dirname "$(tracelink code-ext)")"
else
    curDir="$(pwd)/extensions"
fi

install-extensions() {
    cat $curDir/.extensions | xargs -n1 code --install-extension
}

install-custom-extensions() {
    cp -r ../../DevAssist/vscode-assist/custom_extensions/helmextrasindranil "$HOME"/.vscode/extensions/.
}

install-extensions
install-custom-extensions
