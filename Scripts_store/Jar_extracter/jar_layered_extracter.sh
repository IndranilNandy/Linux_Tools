#!/usr/bin/env sh

# Execute this file in a java project where you have the build.gradle script in the current directory, and use customFatJar to build the fat jar in /build/libs/all-in-one-jar.jar
mkdir -p "./extracted"
(
    cd extracted
    rm -rf *
    jar -xf ../build/libs/all-in-one-jar.jar

    mkdir -p app/classes
    mkdir -p app/libs
    mkdir -p app/rs

    mv ./META-INF app
    mv ./com app/classes
    mv ./javax app/libs
    mv ./org app/libs

    find . -maxdepth 1 -type f -exec mv {} app/rs \;
)