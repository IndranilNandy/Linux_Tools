curDir="./configurer/genericDiffAndMergeToolConfigurer"

sudo chmod +x $curDir/generic_tool
sudo chmod +x $curDir/extMerge
sudo chmod +x $curDir/extDiff
sudo chmod +x $curDir/setgittool

sudo cp $curDir/generic_tool $MYCOMMANDSREPO
sudo cp $curDir/extMerge $MYCOMMANDSREPO
sudo cp $curDir/extDiff $MYCOMMANDSREPO
sudo cp $curDir/setgittool $MYCOMMANDSREPO
sudo cp -i $curDir/.tools $MYCOMMANDSREPO
sudo cp -i $curDir/.commands $MYCOMMANDSREPO

git config --global merge.tool extMerge
git config --global mergetool.extMerge.cmd 'extMerge "$LOCAL" "$BASE" "$REMOTE" "$MERGED"'
git config --global mergetool.extMerge.trustExitCode false
# git config --global diff.external extDiff
git config --global diff.tool extDiff
# git config --global mergetool.extDiff.cmd 'extDiff "$LOCAL" "$REMOTE"'
git config --global difftool.extDiff.cmd 'extDiff "$LOCAL" "$REMOTE"'
