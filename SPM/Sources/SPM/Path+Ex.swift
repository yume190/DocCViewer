//
//  File 2.swift
//  
//
//  Created by Yume on 2024/6/27.
//

import Foundation
import PathKit

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

extension PathKit.Path {
  var firstisDirectory: PathKit.Path? {
    return try? children().first(where: { path in
      path.isDirectory
    })
  }
}
