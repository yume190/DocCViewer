//
//  Repo.swift
//  DocCViewer
//
//  Created by Yume on 2024/7/8.
//

import Foundation
import SwiftGit2
import PathKit

struct Repo: Identifiable, Equatable, Hashable {
  static func == (lhs: Repo, rhs: Repo) -> Bool {
    lhs.path == rhs.path
  }
  func hash(into hasher: inout Hasher) {
    hasher.combine(path)
  }
  
  let id = UUID()
  let path: PathKit.Path
  let repo: Repository
}
