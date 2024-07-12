//
//  File.swift
//  DocCViewer
//
//  Created by Yume on 2024/6/28.
//

import Foundation
import PathKit
import SPM

let queue = DispatchQueue(label: "DocCViewer", qos: .background)

var server: PreviewServer?

var logHandle = LogHandle.standardOutput

extension DoccItem {
  var userRepo: String? {
    if case let .github(user, repo) = doccType {
      return "\(user)_\(repo)"
    }
    return nil
  }
}

enum DoccError: Error {
  case reason(String)
}

extension PathKit.Path {
  func findAll(fileExteion: String, skips: [String] = []) -> [PathKit.Path] {
    do {
      let files = try recursiveChildren()
      return files.filter { path in
        path.extension == fileExteion
      }.filter { path in
        return skips.reduce(true) { sum, next in
          return sum && !path.string.contains(next)
        }
      }
    } catch {
      print("Error: \(error.localizedDescription)")
    }
    
    return []
  }
}
