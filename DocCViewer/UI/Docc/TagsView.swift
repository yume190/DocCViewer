//
//  TagsView.swift
//  DocCViewer
//
//  Created by Yume on 2024/7/1.
//

import Foundation
import SwiftUI
import SwiftGit2
import SPM
import ComposableArchitecture

extension View {
  func repoState(repo: Repo, tag: String) -> RepoState{
    let dir = Paths.tag(repo.repo.user_repo!, tag)
#if canImport(AppKit)
    return dir.exists ? .done: .empty
#elseif canImport(UIKit)
    let repo = DoccPrebuiltState.shared.prebuilts[repo.repo.user_repo!]
    let targetTag = repo?.tags[tag]
    if targetTag == nil {
      return .empty
    }
    return dir.exists ? .done: .build
#else
    return .empty
#endif
  }
}
/// list of tags(x repo)
/// pull & pull all tags
struct TagsView: View {
  //  @Reducer
  //  struct Feature {
  //    @ObservableState
  //    struct State: Equatable {
  //      let repo: Repo
  //    }
  //    enum Action {
  //
  //    }
  //
  //    var body: some Reducer<State, Action> {
  //      Reduce { state, action in
  //        switch action {
  //
  //                  default:
  //                    return .none
  //        }
  //      }
  //    }
  //  }
  //  let store: StoreOf<Feature>
  
  let repo: Repo
  let tags: [TagReference]
  let commits: [String]
  @Binding var selection: Bool
  // TODO: oid tag/commit
  @Binding private var selectedTag: TagReference?
  
  init(repo: Repo, tags: [TagReference], commits: [String], selection: Binding<Bool>, selectedTag: Binding<TagReference?>) {
    self.repo = repo
    self.tags = tags
    self.commits = commits
    self._selection = selection
    self._selectedTag = selectedTag
  }
  
  //  init(repo: Repo, selection: Binding<Bool>, selectedTag: Binding<TagReference?>) {
  //    self.repo = repo
  //    self.tags = (try? repo.repo.allTags().get().reversed()) ?? []
  //    self._selection = selection
  //    self._selectedTag = selectedTag
  //  }
  
  //  @State private var path: [String] = [] // Nothing on the stack by default.
  @EnvironmentObject var prebuilt: DoccPrebuiltState
  var body: some View {
    NavigationStack {
      List {
        ForEach(commits, id: \.self) { commit in
          CommitView(repo: repo, isLatest: false, commit: commit)
            .padding()
            .contentShape(Rectangle()) // 设置点击区域形状
            .onTapGesture {
              //              selectedTag = tag
              self.selection = true
            }
        }
        
        ForEach(tags, id: \.self) { tag in
          TagView(repo: repo, tag: tag.name)
            .padding()
            .contentShape(Rectangle()) // 设置点击区域形状
            .onTapGesture {
#if canImport(AppKit)
              selectedTag = tag
              self.selection = true
              return
#else
              switch repoState(repo: repo, tag: tag.name) {
              case .empty:
                Task { @MainActor in
                  try await api.requestRemoteBuild(repo: repo.repo.url ?? "", tag: tag.name)
                }
                
                print("req build")
              case .build:
                print("start download")
                guard let url = prebuilt.prebuilts[repo.repo.user_repo!]?.tags[tag.name]?.url else {
                  return
                }
                
                Task {
                  do {
                    try await Logic2.downloadTarGzFile(name: repo.repo.user_repo!, tag: tag.name, url: url)
                  } catch {
                    print(error)
                  }
                  print("end download")
                }
              case .done:
                selectedTag = tag
                self.selection = true
              }
#endif
            }
        }
      }
#if canImport(UIKit)
      .navigationBarTitleDisplayMode(.inline)
#endif
      .navigationTitle(repo.repo.user_repo ?? "")
      .toolbar {
        ToolbarItemGroup {
          Button(action: {
            do {
              print("git fetch")
              try repo.repo.fetchOrigin()
            } catch {
              print(error)
            }
          }) {
            Image(systemName: "arrow.down.circle")
          }
        }
      }
      .navigationDestination(isPresented: $selection) {
        if let selectedTag {
          Layer3View(repo: repo.repo, tag: selectedTag, repoState: repoState(repo: repo, tag: selectedTag.name))
        }else{
          EmptyView()
        }
      }
    }.background(Color.black)
    
  }
}

struct CommitView: View {
  @EnvironmentObject var prebuilt: DoccPrebuiltState
  let repo: Repo
  let isLatest: Bool
  let commit: String
  var body: some View {
    
    HStack {
      Text(commit)
      if isLatest {
        Text("(LATEST)")
      }
      Spacer()
      info
      Image(systemName: "chevron.right")
    }
  }
  @ViewBuilder
  var info: some View {
    let dir = Paths.commit(repo.repo.user_repo!, commit)
    if dir.exists {
      Text("Exist")
        .foregroundColor(.cyan)
        .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
        .overlay(
          RoundedRectangle(cornerRadius: 4).stroke(Color.cyan, lineWidth: 1)
        )
    } else {
      Text("None")
        .foregroundColor(.red)
        .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
        .overlay(
          RoundedRectangle(cornerRadius: 4).stroke(Color.red, lineWidth: 1)
        )
    }
    
  }
}


struct TagView: View {
  @EnvironmentObject var prebuilt: DoccPrebuiltState
  let repo: Repo
  let tag: String
  var body: some View {
    
    HStack {
      Text(tag)
      Spacer()
      info
      Image(systemName: "chevron.right")
    }
  }
  
  
  
  var _info: (text: String, color: Color) {
    switch repoState(repo: repo, tag: tag) {
    case .empty:
      return ("None", .red)
    case .build:
      return ("未下載", .green)
    case .done:
      return ("Exist", .cyan)
    }
  }
  
  @ViewBuilder
  var info: some View {
    let setting = _info
    Text(setting.text)
      .foregroundColor(setting.color)
      .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
      .overlay(
        RoundedRectangle(cornerRadius: 4).stroke(setting.color, lineWidth: 1)
      )
    
  }
}
