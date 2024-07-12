//
//  File.swift
//  DocCViewer
//
//  Created by Yume on 2024/7/2.
//

import Foundation
import SwiftUI
import SPM

struct DoccBuildView: View {
  @Binding
  var repoState: RepoState
  
  let repo: Repository
  let tag: TagReference
  var body: some View {
    LazyVStack {
      Button("Build") {
#if canImport(AppKit)
        do {
          _ = try repo.checkout(tag.oid, strategy: .Force).get()
          let action = BuildDocC(
            name: repo.user_repo!,
            url: repo.url!,
            path: Path(repo.directoryURL!.relativePath)
          )
          try action.runMac(tag: tag.name)
          repoState = .build
          //
        } catch {
          
        }
#endif
      }
    }
  }
}


extension String {
  func firstUppercased() -> String {
    guard let first = self.first else {
      return self
    }
    return first.uppercased() + self.dropFirst()
  }
}
