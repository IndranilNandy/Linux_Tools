# This directory contains backups of all cronjobs' definitions
## (with MYCRONTAB definition)

Note:
1. mycrontab job definition is actually translated to actual expression which is used while scheduling with crontab command.
2. This will NOT backup cronjobs scheduled using crontab command. This will ONLY backup cronjobs scheduled using mycrontab command.
3. Backup definition used - mycrontab.

Example.

*[mycrontab definition]*

**indranilnandy   11 * * * * sh $HOME/MyTools/Linux_Tools/Post_setup/mycrontab/cronjobs/testscript.sh**

TRANSLATES TO -

*[crontab definition]*

**indranilnandy 11 * * * * sh /home/indranilnandy/MyTools/Linux_Tools/Post_setup/mycrontab/cronjobs/generated/testscript.sh**