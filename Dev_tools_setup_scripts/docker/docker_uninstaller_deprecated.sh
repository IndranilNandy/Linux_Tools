#!/bin/bash

yes | sudo apt remove docker.io
sudo apt clean
yes | sudo apt autoremove
