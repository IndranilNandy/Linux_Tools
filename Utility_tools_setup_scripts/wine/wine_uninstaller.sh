#!/bin/bash

yes | sudo apt purge wine
sudo apt clean
yes | sudo apt autoremove