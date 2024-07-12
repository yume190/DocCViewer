//
//  File.swift
//
//
//  Created by Yume on 2024/7/2.
//

import Foundation

#if canImport(AppKit)
import SwiftCommand

enum Commands {
  /// At least `Swift 5.10`
  static let swift = Command.findInPath(withName: "swift")
  
  static let dirname = Command.findInPath(withName: "dirname")
  static let tar = Command.findInPath(withName: "tar")
  static let curl = Command.findInPath(withName: "curl")
  static let zip = Command.findInPath(withName: "zip")
  static let git = Command.findInPath(withName: "git")

  static let xcrun = Command.findInPath(withName: "xcrun")
  static let docc = xcrunFind("docc")
  
  
  static func xcrunFind(_ command: String) -> Command<UnspecifiedInputSource, UnspecifiedOutputDestination, UnspecifiedOutputDestination>? {
    let output = try? Commands.xcrun?.addArguments([
      "--find", command,
    ]).waitForOutput()
    if let output {
      return Command(executablePath: .init(output.stdout.replacingOccurrences(of: "\n", with: "")))
    }
    return nil
  }
}
#endif
