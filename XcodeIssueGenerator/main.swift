//
//  main.swift
//  XcodeIssueGenerator
//
//  Created by Sean Coleman on 4/28/16.
//  Copyright © 2016 Sean Coleman. All rights reserved.
//

import Foundation

// Process
let arguments = Process.arguments

var executableName: String?
if let firstArgument = arguments.first {
    executableName = NSURL(fileURLWithPath: firstArgument).lastPathComponent
}

// Environment
let environmentVariables = NSProcessInfo.processInfo().environment
let configuration = environmentVariables["CONFIGURATION"]?.uppercaseString
let sourceRoot = environmentVariables["SRCROOT"]

func main() {
    guard let name = executableName where name.isEmpty == false else {
        print("No executable name.")
        return
    }

    guard let sourceRoot = sourceRoot else {
        print("No $SRCROOT.")
        return
    }

    guard let configuration = configuration else {
        print("No $CONFIGURATION.")
        return
    }

    let argumentParser = ArgumentParser(sourceRoot: sourceRoot)
    guard argumentParser.parseArguments(arguments) else {
        ArgumentParser.printUsage(name)
        return
    }

    if configuration != argumentParser.buildConfig {
        // We only run if the specified build configuration argument matches the Xcode build configuration.
        return
    }

    // If we get this far, we have parsed our arguments and we are satisfied with the environment.

    let tagFinder = TagFinder()
    let errors = tagFinder.findWarnings(argumentParser.warningTags, errors: argumentParser.errorTags, fromPath: sourceRoot, excludeURLs: argumentParser.excludeURLs)

    if errors.error {
        print("An error ocurred while finding tags.")
        return
    }

    if errors.foundErrorTag {
        // We only stop the build if we find at least one error tag.
        exit(EXIT_FAILURE)
    }
}

main()

// TODO: Dogfooding the issue generator with a TODO.
// FIXME: Dogfooding the issue generator with a FIXME.
// WARNING: Dogfooding the issue generator with a WARNING.
// CRITICAL: Dogfooding the issue generator with a CRITICAL.
