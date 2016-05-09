//
//  NSFileManagerExtension.swift
//  XcodeIssueGenerator
//
//  Created by Sean Coleman on 4/30/16.
//  Copyright © 2016 Sean Coleman. All rights reserved.
//

import Foundation

extension NSFileManager {

    static func isDirectory(directory: String) -> Bool {
        var isDirectory: ObjCBool = ObjCBool(false)
        let exists: Bool = NSFileManager.defaultManager().fileExistsAtPath(directory, isDirectory: &isDirectory)

        return exists && Bool(isDirectory)
    }
}
