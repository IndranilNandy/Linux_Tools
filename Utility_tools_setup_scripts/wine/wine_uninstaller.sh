#!/bin/bash

# yes | sudo apt purge wine
yes | sudo apt purge winehq-stable
sudo apt clean
yes | sudo apt autoremove