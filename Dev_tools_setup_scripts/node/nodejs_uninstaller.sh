#!/usr/bin/env bash

yes | sudo n uninstall
yes | sudo npm uninstall -g n
yes | sudo apt remove npm
yes | sudo apt remove nodejs

