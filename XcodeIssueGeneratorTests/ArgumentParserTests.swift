//
//  ArgumentParserTests.swift
//  XcodeIssueGenerator
//
//  Created by Sean Coleman on 4/29/16.
//  Copyright © 2016 Sean Coleman. All rights reserved.
//

import XCTest

/**
    Test parsing arguments that would be passed into the app like this:
    XcodeIssueGenerator -w TODO,WARNING -e CRITICAL -b Release -x Vendor/,ThirdParty/
 */
class ArgumentParserTests: XCTestCase {

    var sourceRoot: String!

    override func setUp() {
        let environmentVariables = NSProcessInfo.processInfo().environment
        sourceRoot = environmentVariables["SRCROOT"]
    }

    func testWarningTags() {
        let arguments = ["XcodeIssueGenerator", "-w", "TODO, WARNING, FIXME"]

        let argumentParser = ArgumentParser(sourceRoot: sourceRoot)
        argumentParser.parseArguments(arguments)

        XCTAssertEqual(argumentParser.warningTags!, ["TODO", "WARNING", "FIXME"], "Warning tags should match TODO, WARNING, and FIXME.")
    }

    func testErrorTags() {
        let arguments = ["XcodeIssueGenerator", "-e", "FIXME,CRITICAL"]

        let argumentParser = ArgumentParser(sourceRoot: sourceRoot)
        argumentParser.parseArguments(arguments)

        XCTAssertEqual(argumentParser.errorTags!, ["FIXME", "CRITICAL"], "Error tags should match FIXME and CRITICAL.")
    }

    func testBuildConfiguration() {
        let arguments = ["XcodeIssueGenerator", "-b", "ADHOC"]

        let argumentParser = ArgumentParser(sourceRoot: sourceRoot)
        argumentParser.parseArguments(arguments)

        XCTAssertEqual(argumentParser.buildConfig!, "ADHOC", "Build configuration should be ADHOC.")
    }

    func testExcludeURLs() {
        let arguments = ["XcodeIssueGenerator", "-w", "FIXME,CRITICAL", "-x", "XcodeIssueGenerator/Exclude Me/, WHAT/"]

        // Also testing invalid exclude directory "WHAT/"

        let argumentParser = ArgumentParser(sourceRoot: sourceRoot)
        argumentParser.parseArguments(arguments)

        XCTAssertTrue(argumentParser.excludeURLs.count == 1, "Although we provided two exclude directories, we expect to parse one exclude directory because the other doesn't exist on disk.")
    }

    func testMissingExcludeURLs() {
        let arguments = ["XcodeIssueGenerator", "-w", "FIXME,CRITICAL", "-x"]

        // Also testing invalid exclude directory "WHAT/"

        let argumentParser = ArgumentParser(sourceRoot: sourceRoot)
        argumentParser.parseArguments(arguments)

        XCTAssertTrue(argumentParser.excludeURLs.count == 0, "Missing exclude directories should result in zero excludeURLs.")
    }

    func testEverything() {
        let arguments = ["XcodeIssueGenerator", "-w", "TODO,WARNING", "-e", "FIXME,CRITICAL", "-b", "ADHOC", "-x", "XcodeIssueGenerator/Exclude Me/, XcodeIssueGenerator/"]

        let argumentParser = ArgumentParser(sourceRoot: sourceRoot)
        argumentParser.parseArguments(arguments)

        XCTAssertEqual(argumentParser.warningTags!, ["TODO", "WARNING"], "Warning tags should match TODO and WARNING.")
        XCTAssertEqual(argumentParser.errorTags!, ["FIXME", "CRITICAL"], "Error tags should match FIXME and CRITICAL.")
        XCTAssertEqual(argumentParser.buildConfig!, "ADHOC", "Build configuration should be ADHOC.")
        XCTAssertTrue(argumentParser.excludeURLs.count == 2, "We expect to parse two exclude directories.")
    }

    func testTooFewArguments() {
        let arguments = ["XcodeIssueGenerator"]
        let argumentParser = ArgumentParser(sourceRoot: sourceRoot)

        XCTAssertFalse(argumentParser.parseArguments(arguments), "Too few arguments for valid program execution.")
    }

    func testInvalidArguments() {
        let arguments = ["XcodeIssueGenerator", "-t", "NOPE"]
        let argumentParser = ArgumentParser(sourceRoot: sourceRoot)

        XCTAssertFalse(argumentParser.parseArguments(arguments), "Invalid arguments for program execution.")
    }
}
