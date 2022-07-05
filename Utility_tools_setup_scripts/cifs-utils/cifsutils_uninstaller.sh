#!/bin/bash

yes | sudo apt remove cifs-utils
sudo apt clean
yes | sudo apt autoremove