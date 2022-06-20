#!/bin/bash

yes | sudo apt remove meld
sudo apt clean
yes | sudo apt autoremove