#!/bin/bash

yes | sudo apt remove nmap
sudo apt clean
yes | sudo apt autoremove