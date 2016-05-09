//
//  ArgumentParser.swift
//  XcodeIssueGenerator
//
//  Created by Sean Coleman on 4/28/16.
//  Copyright © 2016 Sean Coleman. All rights reserved.
//

import Foundation

class ArgumentParser {

    // MARK: - Static

    struct K {
        static let InsufficientArgumentsMessage = "Insufficient arguments provided for option."
        static let CouldNotMakeExcludeDirectoryMessage = "Could not make exclude directory. Directories should be relative to the project file which is the same as being relative to ($SRCROOT)."
    }

    static func printUsage(executableName: String) {
        print("Usage:")
        print("\t\(executableName) -w warning tags -e error tags -b build configuration -x exclude directories")
    }

    // MARK: - ArgumentParser

    // MARK: Lifetime

    init(sourceRoot: String) {
        self.sourceRoot = sourceRoot
    }

    // MARK: Internal

    let sourceRoot: String

    var warningTags: [String]?
    var errorTags: [String]?
    var buildConfig: String?

    var excludeURLs = [NSURL]()

    /**
     Parse arguments into warning tags, error tags, build configuration, and exclude URLs.

     - parameter arguments: An array of argument strings.

     - returns: Bool indicating if we met the minimum argument requirements.
     */
    func parseArguments(arguments: [String]) -> Bool {
        var argumentsGenerator = arguments.generate()

        while let arg = argumentsGenerator.next() {
            switch arg {
            case "-w":
                if let next = argumentsGenerator.next() {
                    warningTags = splitList(next)
                } else {
                    print(K.InsufficientArgumentsMessage)
                }
            case "-e":
                if let next = argumentsGenerator.next() {
                    errorTags = splitList(next)
                } else {
                    print(K.InsufficientArgumentsMessage)
                }
            case "-b":
                if let next = argumentsGenerator.next() {
                    buildConfig = next
                } else {
                    print(K.InsufficientArgumentsMessage)
                }
            case "-x":
                if let next = argumentsGenerator.next() {
                    let excludePaths = splitList(next)
                    excludeURLs.appendContentsOf(makeURLsFromExcludePaths(excludePaths))
                } else {
                    print(K.InsufficientArgumentsMessage)
                }
            default:
                break
            }
        }

        // Minimum requirements are we have warning tags or error tags and also a build configuration.
        if (warningTags?.isEmpty == false || errorTags?.isEmpty == false) && buildConfig?.isEmpty == false {
            return true
        } else {
            return false
        }
    }

    // MARK: Private

    /**
     Split a comma-delimited string into an Array of strings.

     - parameter list: Lists should be comma-separated strings: "TODO,FIXME"

     - returns: Array of strings with whitespace trimmed.
    */
    private func splitList(list: String?) -> [String]? {
        guard let list = list else { return nil }

        let components = list.componentsSeparatedByString(",")

        return components.map { $0.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) }
    }

    private func makeURLsFromExcludePaths(excludePaths: [String]?) -> [NSURL] {
        guard let excludePaths = excludePaths else { return [] }

        var excludeURLs = [NSURL]()

        for excludePath in excludePaths {
            let fullExcludePath = "\(sourceRoot)/\(excludePath)"

            if NSFileManager.isDirectory(fullExcludePath) {
                excludeURLs.append(NSURL(fileURLWithPath: fullExcludePath))
            } else {
                print(K.CouldNotMakeExcludeDirectoryMessage)
            }
        }

        return excludeURLs
    }
}
