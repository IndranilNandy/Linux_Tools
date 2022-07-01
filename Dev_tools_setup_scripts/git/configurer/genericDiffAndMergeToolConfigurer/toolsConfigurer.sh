curDir="$(pwd)/configurer/genericDiffAndMergeToolConfigurer"

sudo chmod +x $curDir/generic_tool
sudo chmod +x $curDir/extMerge
sudo chmod +x $curDir/extDiff
sudo chmod +x $curDir/setgittool

yes | sudo ln -i -s $curDir/extMerge $MYCOMMANDSREPO/extMerge
yes | sudo ln -i -s $curDir/extDiff $MYCOMMANDSREPO/extDiff

git config --global merge.tool extMerge
git config --global mergetool.extMerge.cmd 'extMerge "$LOCAL" "$BASE" "$REMOTE" "$MERGED"'
git config --global mergetool.extMerge.trustExitCode false
# git config --global diff.external extDiff
git config --global diff.tool extDiff
# git config --global mergetool.extDiff.cmd 'extDiff "$LOCAL" "$REMOTE"'
git config --global difftool.extDiff.cmd 'extDiff "$LOCAL" "$REMOTE"'
