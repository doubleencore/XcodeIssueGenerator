//
//  ArgumentParser.swift
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

class ArgumentParser {

    // MARK: - Static

    struct K {
        static let InsufficientArgumentsMessage = "Insufficient arguments provided for option."
        static let CouldNotMakeExcludeDirectoryMessage = "Could not make exclude directory. Directories should be relative to the project file which is the same as being relative to ($SRCROOT)."
    }

    static func printUsage(_ executableName: String) {
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

    var excludeURLs = [URL]()

    /**
     Parse arguments into warning tags, error tags, build configuration, and exclude URLs.

     - parameter arguments: An array of argument strings.

     - returns: Bool indicating if we met the minimum argument requirements.
     */
    func parse(_ arguments: [String]) -> Bool {
        var argumentsGenerator = arguments.makeIterator()

        while let arg = argumentsGenerator.next() {
            switch arg {
            case "-w":
                if let next = argumentsGenerator.next() {
                    warningTags = split(list: next)
                } else {
                    print(K.InsufficientArgumentsMessage)
                }
            case "-e":
                if let next = argumentsGenerator.next() {
                    errorTags = split(list: next)
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
                    let excludePaths = split(list: next)
                    excludeURLs.append(contentsOf: makeURLs(from: excludePaths))
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
    private func split(list: String?) -> [String]? {
        guard let list = list else { return nil }

        let components = list.components(separatedBy: ",")

        return components.map { $0.trimmingCharacters(in: CharacterSet.whitespaces) }
    }

    private func makeURLs(from excludePaths: [String]?) -> [URL] {
        guard let excludePaths = excludePaths else { return [] }

        var excludeURLs = [URL]()

        for excludePath in excludePaths {
            let fullExcludePath = "\(sourceRoot)/\(excludePath)"

            if FileManager.isDirectory(fullExcludePath) {
                excludeURLs.append(URL(fileURLWithPath: fullExcludePath))
            } else {
                print(K.CouldNotMakeExcludeDirectoryMessage)
            }
        }

        return excludeURLs
    }
}
