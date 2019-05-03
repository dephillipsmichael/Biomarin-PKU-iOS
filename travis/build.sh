#!/bin/sh
set -ex
if [[ "$TRAVIS_PULL_REQUEST" != "false" ]]; then     # on pull requests
    echo "Build on PR"
    # syoung 05/02/2019 If you wish to run tests on pull requests, you will need to set up a test app that does not hook to bridge.
    # FASTLANE_EXPLICIT_OPEN_SIMULATOR=2 bundle exec fastlane test scheme:"BiomarinPKUTestApp"
elif [[ -z "$TRAVIS_TAG" && "$TRAVIS_BRANCH" == "master" ]]; then  # non-tag commits to master branch
    echo "Build on merge to master"
    # git clone https://github.com/Sage-Bionetworks/iOSPrivateProjectInfo.git ../iOSPrivateProjectInfo
    # FASTLANE_EXPLICIT_OPEN_SIMULATOR=2 bundle exec fastlane test scheme:"BiomarinPKU"
    # bundle exec fastlane keychains
    # bundle exec fastlane certificates
    # bundle exec fastlane ci_archive scheme:"BiomarinPKU" export_method:"app-store" project:"BiomarinPKU/BiomarinPKU.xcodeproj"
elif [[ -z "$TRAVIS_TAG" && "$TRAVIS_BRANCH" =~ ^stable-.* ]]; then # non-tag commits to stable branches
    echo "Build on stable branch"
    git clone https://github.com/Sage-Bionetworks/iOSPrivateProjectInfo.git ../iOSPrivateProjectInfo
    FASTLANE_EXPLICIT_OPEN_SIMULATOR=2 bundle exec fastlane test scheme:"BiomarinPKU"
    bundle exec fastlane keychains
    bundle exec fastlane certificates
    bundle exec fastlane beta scheme:"BiomarinPKU" export_method:"app-store" project:"BiomarinPKU/BiomarinPKU.xcodeproj"
fi
exit $?
