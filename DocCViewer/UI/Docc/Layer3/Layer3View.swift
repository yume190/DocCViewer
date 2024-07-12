//
//  Layer3View.swift
//  DocCViewer
//
//  Created by Yume on 2024/7/10.
//

import Foundation
import SwiftUI
import SPM

struct Layer3View: View {
  let repo: Repository
  let tag: TagReference
  
  @State
  var repoState: RepoState
  
  var body: some View {
#if canImport(UIKit)
    DoccPreviewView(repo: repo, tag: tag)
#else
    switch repoState {
    case .done:
      DoccPreviewView(repo: repo, tag: tag)
    case .build:
      EmptyView()
    case .empty:
      DoccBuildView(repoState: $repoState, repo: repo, tag: tag)
        .onAppear {
          repoState  = Paths.tag(repo.user_repo!, tag.name).exists ? .build:.empty
        }
    }
#endif
  }
}
