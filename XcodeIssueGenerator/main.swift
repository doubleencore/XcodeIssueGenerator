//
//  main.swift
//
//  Copyright (c) 2016 POSSIBLE Mobile (https://possiblemobile.com)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
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
// WARNING: Dogfooding the issue generator with a WARNING.
