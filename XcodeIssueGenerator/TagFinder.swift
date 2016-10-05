//
//  TagFinder.swift
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

struct TagFinder {

    // MARK: - Static

    struct K {
        static let markableFileExtensions = ["swift", "h", "hh", "m", "mm", "cc", "cpp"]
    }

    // MARK: - TagFinder

    // MARK: Internal

    func find(warnings: [String]?, errors: [String]?, fromPath: String?, excludeURLs: [URL]) -> (foundErrorTag: Bool, error: Bool) {
        guard let enumerator = createEnumerator(fromPath) else { return (false, true) }

        var foundErrorTag = false

        let warningRegex = makeRegex(with: warnings)
        let errorRegex = makeRegex(with: errors)

        while let URL = enumerator.nextObject() as? URL {
            if FileManager.isDirectory(URL.path) || K.markableFileExtensions.contains(URL.pathExtension) == false {
                // Skip directories and file extensions we do not care about.
                continue
            }

            // Skip files in directories that are in the exclude list.
            if path(URL.path, excludedByURLs: excludeURLs) {
                continue
            }

            var text: String
            do {
                text = try String(contentsOfFile: URL.path, encoding: String.Encoding.utf8)
            } catch _ as NSError {
                print("File IO error for path: \(URL.path).")
                continue
            }

            let lineArray = text.components(separatedBy: "\n")

            // Find issue comments in the file, print a line with the issue type prepended to the comment line.
            for (lineNumber, line) in lineArray.enumerated() {
                if let warningRegex = warningRegex {
                    let warningMatches = matches(for: warningRegex, inText: line)

                    warningMatches.forEach { print("\(URL.path):\(lineNumber + 1): warning: \($0)") }
                }

                if let errorRegex = errorRegex {
                    let errorMatches = matches(for: errorRegex, inText: line)

                    errorMatches.forEach { print("\(URL.path):\(lineNumber + 1): error: \($0)") }

                    if errorMatches.isEmpty == false { foundErrorTag = true }
                }
            }
        }

        return (foundErrorTag, false)
    }

    // MARK: Private

    private func path(_ path: String, excludedByURLs excludeURLs: [URL]) -> Bool {

        func clean(path: String?) -> String? {
            return path?.lowercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }

        for excludeURL in excludeURLs {
            if let path = clean(path: path), let excludePath = clean(path: excludeURL.path) {
                if path.truncate(length: excludePath.characters.count) == excludePath {
                    return true
                }
            }
        }

        return false
    }

    private func makeRegex(with tags: [String]?) -> NSRegularExpression? {
        guard let tags = tags else { return nil }

        let pattern = "//\\s*(\(tags.joined(separator: "|"))):.*$"

        do {
            return try NSRegularExpression(pattern: pattern, options: [])
        } catch _ as NSError {
            print("Error making regex with tags: \(tags)")
            return nil
        }
    }

    private func createEnumerator(_ sourceRoot: String?) -> FileManager.DirectoryEnumerator? {
        guard let sourceRoot = sourceRoot else {
            print("No $SRCROOT.")
            return nil
        }

        guard let escapedSourceRoot = sourceRoot.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
            print("Could not escape $SRCROOT.")
            return nil
        }

        guard let sourceRootURL = URL(string: escapedSourceRoot) else {
            print("Could not create NSURL from escaped $SRCROOT.")
            return nil
        }

        guard FileManager.isDirectory(sourceRoot) else { return nil }

        return FileManager.default.enumerator(at: sourceRootURL,
                                                              includingPropertiesForKeys: nil,
                                                              options: [.skipsHiddenFiles],
                                                              errorHandler: nil)
    }

    private func matches(for regex: NSRegularExpression, inText text: String) -> [String] {
        let nsString = text as NSString
        let results = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))

        return results.map { nsString.substring(with: $0.range) }
    }
}
