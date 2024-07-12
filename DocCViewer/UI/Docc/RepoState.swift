//
//  DoccState.swift
//  DocCViewer
//
//  Created by Yume on 2024/7/10.
//

import Foundation

/// ios state
///   empty -> `request build` -> build
///   build -> `download`      -> done
///
/// mac state
///   empty -> `build`         -> done
enum RepoState {
  case empty
  case build
  case done
}
