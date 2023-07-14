#!/usr/bin/env bash

typeid=""
typetoken="type"
languageid="id 'java'"
languagetoken="language"
platformversionid="id 'org.springframework.boot'"
platformversiontoken="platformVersion"
packagingid="id 'war'"
packagingtoken="packaging"
jvmversionid="sourceCompatibility"
jvmversiontoken="jvmVersion"
groupid="group"
grouptoken="groupId"
artifactid=""
artifacttoken="artifactId"
nameid=""
nametoken="name"
descriptionid=""
descriptiontoken="description"
packageid=""
packagetoken="packageName"
dependenciesid=""
dependenciestoken="dependencies"

build_file() {
    echo "$(pwd)/build.gradle"
}

extract_type() {
    echo "gradle-project"
}

extract_language() {
    grep -q " *$languageid$" "$(build_file)" && echo "java" && return 0
    echo -e "Language not identified" && return 1
}

extract_platform_version() {
    grep " *$platformversionid" "$(build_file)" | awk '{ print $NF }' | sed "s/'\(.*\)'/\1/"
}

extract_packaging() {
    grep -q " *$packagingid$" "$(build_file)" && echo "war" && return 0
    echo "jar" && return 0
}

extract_jvm_version() {
    grep " *$jvmversionid" "$(build_file)" | awk '{ print $NF }' | sed "s/'\(.*\)'/\1/"
}

extract_group() {
    grep " *$groupid" "$(build_file)" | awk '{ print $NF }' | sed "s/'\(.*\)'/\1/"
}
extract_artifact() {
    # It is shown in settings.gradle. As it doesn't appear on build.gradle, no need to extract it.
    echo "demo"
}

extract_name() {
    echo "demo"
}

extract_description() {
    echo "demo_description"
}

extract_package() {
    echo "$(extract_group).$(extract_artifact)"
}

extract_dependencies() {
    echo "nothing"
}

extract_project_url() {
    echo "https://start.spring.io/#!\
$typetoken=$(extract_type)&\
$languagetoken=$(extract_language)&\
$platformversiontoken=$(extract_platform_version)&\
$packagingtoken=$(extract_packaging)&\
$jvmversiontoken=$(extract_jvm_version)&\
$grouptoken=$(extract_group)&\
$artifacttoken=$(extract_artifact)&\
$nametoken=$(extract_name)&\
$descriptiontoken=$(extract_description)&\
$packagetoken=$(extract_package)"
}

# get_project_url