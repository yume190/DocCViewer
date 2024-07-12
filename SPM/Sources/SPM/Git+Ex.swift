//
//  File.swift
//  
//
//  Created by Yume on 2024/7/2.
//

import Foundation
import SwiftGit2
import libgit2


enum GitError: Error {
  case reason(method: String, code: Int32)
}

public extension Repository {
  
  func fetchOrigin() throws {
    if let origin {
      try fetch(origin).get()
    }
  }
  var origin: Remote? {
    return try? remote(named: "origin").get()
  }
  
  var main: Branch? {
    try? localBranch(named: "main").get()
  }
  
  var master: Branch? {
    try? localBranch(named: "master").get()
  }
  
  var url: String? {
    origin?.URL
  }
  
  var user_repo: String? {
    guard let url else {return nil}
    return findGithubUserRepo(url)
  }
  
  private func remoteLookup<A>(named name: String, _ callback: (Result<OpaquePointer, Error>) -> A) -> A {
    var pointer: OpaquePointer? = nil
    defer { git_remote_free(pointer) }

    let result = git_remote_lookup(&pointer, self.pointer, name)

    guard result == GIT_OK.rawValue else {
      return callback(.failure(
        GitError.reason(method: "git_remote_lookup", code: result)
      ))
    }

    return callback(.success(pointer!))
  }
  
  /// ``git_remote_autotag_option_t``
  struct RemoteAutotagOption {
    let rawValue: git_remote_autotag_option_t
    public static let unspecyfied = RemoteAutotagOption(rawValue: GIT_REMOTE_DOWNLOAD_TAGS_UNSPECIFIED)
    public static let auto        = RemoteAutotagOption(rawValue: GIT_REMOTE_DOWNLOAD_TAGS_AUTO)
    public static let none        = RemoteAutotagOption(rawValue: GIT_REMOTE_DOWNLOAD_TAGS_NONE)
    public static let all         = RemoteAutotagOption(rawValue: GIT_REMOTE_DOWNLOAD_TAGS_ALL)
  }
  
  /// Download new data and update tips
  func fetch2(_ remote: Remote, _ option: RemoteAutotagOption = .all) -> Result<(), Error> {
    return remoteLookup(named: remote.name) { remote in
      remote.flatMap { pointer in
        var opts = git_fetch_options()
        let resultInit = git_fetch_init_options(&opts, UInt32(GIT_FETCH_OPTIONS_VERSION))
        opts.download_tags = option.rawValue
        assert(resultInit == GIT_OK.rawValue)

        let result = git_remote_fetch(pointer, nil, &opts, nil)
        guard result == GIT_OK.rawValue else {
          let err = GitError.reason(method: "git_remote_fetch", code: result)
          return .failure(err)
        }
        return .success(())
      }
    }
  }

//  func peal(head: ReferenceType)  {
//    func head() -> OpaquePointer? {
//      var pointer: OpaquePointer? = nil
//      let result = git_repository_head(&pointer, self.pointer)
//      guard result == GIT_OK.rawValue else {return nil}
//      return pointer
//    }
//    
//    func peal(head: OpaquePointer) -> OpaquePointer? {
//      var pointer: OpaquePointer? = nil
//      let result = git_reference_peel(&pointer, head, GIT_OBJECT_COMMIT)
//      guard result == GIT_OK.rawValue else {return nil}
//      return pointer
//    }
//    guard let headRef = head() else {
//      return
//    }
//    guard let headObj = peal(head: headRef) else {
//      return
//    }
//    
//    var headCommit: OpaquePointer? = nil
////    var opt = merge_options()
//    var mergeOption = git_merge_options()
////    int git_merge(
////      git_repository *repo,
////      const git_annotated_commit **their_heads,
////      size_t their_heads_len,
////      const git_merge_options *merge_opts,
////      const git_checkout_options *given_checkout_opts)
//    
////    let result = git_merge(self.pointer, &headCommit, <#T##their_heads_len: Int##Int#>, &mergeOption, nil)
//    
////    git_commit *head_commit = (git_commit *)head_obj;
////    git_merge_options merge_opts = GIT_MERGE_OPTIONS_INIT;
////    error = git_merge(repo, head_commit, NULL, &merge_opts, NULL);
////    if (error < 0) {
////        printf("Error merging: %d\n", error);
////        return -1;
////    }
//    
//    //  git_object *head_obj = NULL;
//    //  error = git_reference_peel(&head_obj, head_ref, GIT_OBJECT_COMMIT);
//    //  if (error < 0) {
//    //      printf("Error peeling reference: %d\n", error);
//    //      return -1;
//    //  }
//
////    var pointer: OpaquePointer? = nil
////    let result = git_reference_peel(&pointer, head., self.pointer)
////    guard result == GIT_OK.rawValue else {
////      return Result.failure(NSError(gitError: result, pointOfFailure: "git_repository_head"))
////    }
////    let value = referenceWithLibGit2Reference(pointer!)
////    git_reference_free(pointer)
////    return Result.success(value)
//  }
  
//  git_reference *head_ref = NULL;
//  error = git_repository_head(&head_ref, repo);
//  if (error < 0) {
//      printf("Error getting HEAD reference: %d\n", error);
//      return -1;
//  }
//
}
