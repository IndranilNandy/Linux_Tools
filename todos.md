# List of pending tasks

- [ ] Add uninstallation scripts for each tool.
- [ ] Add 'full uninstallation' or 'clean' script.
- [ ] Add data backup for vscode configurations (extensions, settings, extension specific settings file like project manager's settings)
- [ ] Data and code segregation
- [ ] Partition 'Data segment' in two parts - 1. Global settings data, applicable to all machines/users, 2. Local machine/user specific.
- [ ] Centralize script configuration variables in YAML files.
- [x] Separate WSD tool (which is still incomplete) from git repos' sync tool (name it 'ws')
- [ ] Add cron tasks for various jobs, like periodic checking of local git repos.
- [x] Enhance performance of qcd by removing unnecessary call to buildqcdmap.
- [x] Add separate options for workspaces configuration in qcd, qn etc.
- [x] Update 'ws' tool to download, monitor status, load, list all git workspaces from a single point.
- [ ] For 'mycompl' command, split .genericcompletions in two separate files - 1. to store static completions, i.e. populated during initial setup, 2. to store dynamic completions, i.e., populated during every shell initialization (e.g. bash function arguments/options).
