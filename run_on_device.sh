#!/bin/bash
export ANDROID_HOME=~/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools
export GRADLE_USER_HOME=~/.gradle
export GRADLE_OPTS="-Dorg.gradle.project.kotlin.compiler.execution.strategy=in-process -Dkotlin.compiler.execution.strategy=in-process"

cd "$(dirname "$0")"
flutter run -d R5CXA0T1WKL
