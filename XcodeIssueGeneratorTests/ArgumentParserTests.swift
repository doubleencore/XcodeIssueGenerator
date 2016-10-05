//
//  ArgumentParserTests.swift
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

import XCTest

/**
    Test parsing arguments that would be passed into the app like this:
    XcodeIssueGenerator -w TODO,WARNING -e CRITICAL -b Release -x Vendor/,ThirdParty/
 */
class ArgumentParserTests: XCTestCase {

    var sourceRoot: String!

    override func setUp() {
        let environmentVariables = ProcessInfo.processInfo.environment
        sourceRoot = environmentVariables["SRCROOT"]
    }

    func testWarningTags() {
        let arguments = ["XcodeIssueGenerator", "-w", "TODO, WARNING, FIXME"]

        let argumentParser = ArgumentParser(sourceRoot: sourceRoot)
        _ = argumentParser.parse(arguments)

        XCTAssertEqual(argumentParser.warningTags!, ["TODO", "WARNING", "FIXME"], "Warning tags should match TODO, WARNING, and FIXME.")
    }

    func testErrorTags() {
        let arguments = ["XcodeIssueGenerator", "-e", "FIXME,CRITICAL"]

        let argumentParser = ArgumentParser(sourceRoot: sourceRoot)
        _ = argumentParser.parse(arguments)

        XCTAssertEqual(argumentParser.errorTags!, ["FIXME", "CRITICAL"], "Error tags should match FIXME and CRITICAL.")
    }

    func testBuildConfiguration() {
        let arguments = ["XcodeIssueGenerator", "-b", "ADHOC"]

        let argumentParser = ArgumentParser(sourceRoot: sourceRoot)
        _ = argumentParser.parse(arguments)

        XCTAssertEqual(argumentParser.buildConfig!, "ADHOC", "Build configuration should be ADHOC.")
    }

    func testExcludeURLs() {
        let arguments = ["XcodeIssueGenerator", "-w", "FIXME,CRITICAL", "-x", "XcodeIssueGenerator/Exclude Me/, WHAT/"]

        // Also testing invalid exclude directory "WHAT/"

        let argumentParser = ArgumentParser(sourceRoot: sourceRoot)
        _ = argumentParser.parse(arguments)

        XCTAssertTrue(argumentParser.excludeURLs.count == 1, "Although we provided two exclude directories, we expect to parse one exclude directory because the other doesn't exist on disk.")
    }

    func testMissingExcludeURLs() {
        let arguments = ["XcodeIssueGenerator", "-w", "FIXME,CRITICAL", "-x"]

        // Also testing invalid exclude directory "WHAT/"

        let argumentParser = ArgumentParser(sourceRoot: sourceRoot)
        _ = argumentParser.parse(arguments)

        XCTAssertTrue(argumentParser.excludeURLs.count == 0, "Missing exclude directories should result in zero excludeURLs.")
    }

    func testEverything() {
        let arguments = ["XcodeIssueGenerator", "-w", "TODO,WARNING", "-e", "FIXME,CRITICAL", "-b", "ADHOC", "-x", "XcodeIssueGenerator/Exclude Me/, XcodeIssueGenerator/"]

        let argumentParser = ArgumentParser(sourceRoot: sourceRoot)
        _ = argumentParser.parse(arguments)

        XCTAssertEqual(argumentParser.warningTags!, ["TODO", "WARNING"], "Warning tags should match TODO and WARNING.")
        XCTAssertEqual(argumentParser.errorTags!, ["FIXME", "CRITICAL"], "Error tags should match FIXME and CRITICAL.")
        XCTAssertEqual(argumentParser.buildConfig!, "ADHOC", "Build configuration should be ADHOC.")
        XCTAssertTrue(argumentParser.excludeURLs.count == 2, "We expect to parse two exclude directories.")
    }

    func testTooFewArguments() {
        let arguments = ["XcodeIssueGenerator"]
        let argumentParser = ArgumentParser(sourceRoot: sourceRoot)

        XCTAssertFalse(argumentParser.parse(arguments), "Too few arguments for valid program execution.")
    }

    func testInvalidArguments() {
        let arguments = ["XcodeIssueGenerator", "-t", "NOPE"]
        let argumentParser = ArgumentParser(sourceRoot: sourceRoot)

        XCTAssertFalse(argumentParser.parse(arguments), "Invalid arguments for program execution.")
    }
}
