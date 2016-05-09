//
//  StringExtension.swift
//  XcodeIssueGenerator
//
//  Created by Sean Coleman on 5/1/16.
//  Copyright © 2016 Sean Coleman. All rights reserved.
//

import Foundation

extension String {

    func truncate(length: Int) -> String {
        if self.characters.count > length {
            return self.substringToIndex(self.startIndex.advancedBy(length))
        } else {
            return self
        }
    }
}
