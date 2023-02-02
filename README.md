# Curtz iOS App

[![Curtz](https://github.com/SanctumLabs/curtz-ios/actions/workflows/build_and_test.yml/badge.svg)](https://github.com/SanctumLabs/curtz-ios/actions/workflows/build_and_test.yml)
[![codecov](https://codecov.io/github/SanctumLabs/curtz-ios/branch/master/graph/badge.svg?token=Oey4LIlL6f)](https://codecov.io/github/SanctumLabs/curtz-ios)
[![License](https://img.shields.io/badge/License-MIT-red.svg)](https://opensource.org/licenses/MIT)

Simple URL Shortner service iOS application

## Getting Started
Ensure you have the following setup on you local development environment:
 - Machine capable of running macOS
 - Machine capable of running Xcode


## Running the application
- To ensure that your machine remains clean during and after develop at the root of the project run `bundle config set --local path 'vendor/bundle'` to set the path where the ruby dependecies will be downloaded to
- Install the dependencies by running `bundle install`.
- Generate the project file by running `bundle exec fastlane setup`, which will use the `project.yml` to generate the Xcodeproj.
- Using Xcode open the generated Xcodeproj and switch between the schemes available.

## Testing the application
TODO

## Why we don't ship the `.xcodeproj` file
To avoid the mess of an experience while merging `*.xcodeproj` file conflicts, This project will utilize [Xcodegen](https://github.com/yonaskolb/XcodeGen) a tool the generates Xcode project using our folder structure and a project specification file `project.yml`

## License
View the project license [here](./LICENSE)


[UseCases](./USECASES.md)