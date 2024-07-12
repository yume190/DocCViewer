//
//  Paths.swift
//  DocCViewer
//
//  Created by Yume on 2024/7/1.
//

import PathKit
import Foundation

private var doc: URL {
  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
}

public var path: Path {
  PathKit.Path(doc.relativePath) + "DocCViewer"
}

// DOCC_HTML_DIR
// https://github.com/apple/swift-docc-render-artifact
// https://github.com/apple/swift-docc-render
public var html: Path {
  PathKit.Path(Bundle.module.url(forResource: "dist", withExtension: nil)!.relativePath)
}

public enum Paths {
  static var doc: URL {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
  }

  public static var base: Path {
    PathKit.Path(doc.relativePath) + "DocCViewer"
  }
  public static var git: Path { base + "git" }
  public static var build: Path { base + "build" }
  public static var dist: Path { base + "dist" }
  public static func tag(_ user_repo: String, _ tag: String) -> Path {
    dist + user_repo + "tags" + tag
  }
  
  public static func commit(_ user_repo: String, _ commit: String) -> Path {
    dist + user_repo + "commits" + commit
  }
}
