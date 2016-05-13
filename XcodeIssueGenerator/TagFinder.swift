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
        static let markableFileExtensions = ["swift", "h", "m"]
    }

    // MARK: - TagFinder

    // MARK: Internal

    func findWarnings(warnings: [String]?, errors: [String]?, fromPath: String?, excludeURLs: [NSURL]) -> (foundErrorTag: Bool, error: Bool) {
        guard let enumerator = createEnumerator(fromPath) else { return (false, true) }

        var foundErrorTag = false

        let warningRegex = makeRegexWithTags(warnings)
        let errorRegex = makeRegexWithTags(errors)

        while let URL = enumerator.nextObject() as? NSURL, ext = URL.pathExtension, urlPath = URL.path {
            if NSFileManager.isDirectory(urlPath) || K.markableFileExtensions.contains(ext) == false {
                // Skip directories and file extensions we do not care about.
                continue
            }

            // Skip files in directories that are in the exclude list.
            if path(urlPath, excludedByURLs: excludeURLs) {
                continue
            }

            var text: String
            do {
                text = try String(contentsOfFile: urlPath, encoding: NSUTF8StringEncoding)
            } catch _ as NSError {
                print("File IO error for path: \(urlPath).")
                continue
            }

            let lineArray = text.componentsSeparatedByString("\n")

            // Find issue comments in the file, print a line with the issue type prepended to the comment line.
            for (lineNumber, line) in lineArray.enumerate() {
                if let warningRegex = warningRegex {
                    let warningMatches = matchesForRegex(warningRegex, inText: line)

                    warningMatches.forEach { print("\(urlPath):\(lineNumber + 1): warning: \($0)") }
                }

                if let errorRegex = errorRegex {
                    let errorMatches = matchesForRegex(errorRegex, inText: line)

                    errorMatches.forEach { print("\(urlPath):\(lineNumber + 1): error: \($0)") }

                    if errorMatches.isEmpty == false { foundErrorTag = true }
                }
            }
        }

        return (foundErrorTag, false)
    }

    // MARK: Private

    private func path(path: String, excludedByURLs excludeURLs: [NSURL]) -> Bool {

        func cleanPath(path: String?) -> String? {
            return path?.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        }

        for excludeURL in excludeURLs {
            if let path = cleanPath(path), excludePath = cleanPath(excludeURL.path) {
                if path.truncate(excludePath.characters.count) == excludePath {
                    return true
                }
            }
        }

        return false
    }

    private func makeRegexWithTags(tags: [String]?) -> NSRegularExpression? {
        guard let tags = tags else { return nil }

        let pattern = "//\\s*(\(tags.joinWithSeparator("|"))):.*$"

        do {
            return try NSRegularExpression(pattern: pattern, options: [])
        } catch _ as NSError {
            print("Error making regex with tags: \(tags)")
            return nil
        }
    }

    private func createEnumerator(sourceRoot: String?) -> NSDirectoryEnumerator? {
        guard let sourceRoot = sourceRoot, sourceRootURL = NSURL(string: sourceRoot) else { return nil }
        guard NSFileManager.isDirectory(sourceRoot) else { return nil }

        return NSFileManager.defaultManager().enumeratorAtURL(sourceRootURL,
                                                              includingPropertiesForKeys: nil,
                                                              options: [.SkipsHiddenFiles],
                                                              errorHandler: nil)
    }

    private func matchesForRegex(regex: NSRegularExpression, inText text: String) -> [String] {
        let nsString = text as NSString
        let results = regex.matchesInString(text, options: [], range: NSRange(location: 0, length: nsString.length))

        return results.map { nsString.substringWithRange($0.range) }
    }
}
