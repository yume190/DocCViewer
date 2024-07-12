//
//  DocList.swift
//  DoccViewer
//
//  Created by Yume on 2024/6/20.
//

import SwiftUI
import SwiftGit2
import PathKit
import ComposableArchitecture
import SPM



struct DocCListView: View {
  @Reducer
  struct Feature {
    @ObservableState
    struct State: Equatable {
      var repos: [Repo]
      var detail: Repo?
      
      //      @Presents
      //      var detail2: TagsView.Feature.State?
      
    }
    enum Action {
      case repoLoading
      case repoLoaded(repos: [Repo])
      
      case addRepo(url: String)
      case select(repo: Repo)
      
      //      case detail(PresentationAction<TagsView.Feature.Action>)
    }
    
    var body: some Reducer<State, Action> {
      Reduce { state, action in
        switch action {
        case .addRepo(let url):
          return .run { send in
            guard let name = findGithubUserRepo(url) else { return }
            guard let source = URL(string: url) else { return }
            
            let target = (Paths.git + name)
            if target.exists {
              do {
                _ = try Repository.at(target.url).get()
                print("REPO \(target.lastComponent) exist")
              } catch {
                try? target.delete()
              }
            } else {
              do {
                try target.mkpath()
                
                _ = try Repository.clone(from: source, to: target.url).get()
                await send(.repoLoading)
              } catch {
                try? target.delete()
                print(error)
              }
            }
          }
        case .repoLoading:
          return .run { send in
            print("Reload Repos")
            try Paths.git.mkpath()
            let dirs = try Paths.git.children()
            let repos = dirs.compactMap { path in
              if let repo = try? Repository.at(path.url).get() {
                return Repo(path: path, repo: repo)
              }
              return nil
            }
            await send(.repoLoaded(repos: repos))
          }
        case .repoLoaded(let repos):
          state.repos = repos
          
          return .none
        case .select(let repo):
          state.detail = repo
          //          state.detail2 = .init(repo: repo)
          return .none
//        default:
//          return .none
        }
      }
      //      .ifLet(\.$detail2, action: \.detail) {
      //        TagsView.Feature()
      //      }
    }
  }
  let store: StoreOf<Feature>
  
  
  
  
  /// layer1
  @State private var selection2: Repo?
  /// layer2
  @State private var selection: Bool = false
  @State private var selectedTag: TagReference?
  
  /// Alert
  @State private var showAlert = false
  @State private var inputText = "https://github.com/apple/swift-argument-parser"
//  @State private var inputText = "https://github.com/pointfreeco/swift-composable-architecture"
  
  @State var isSideBarShow: NavigationSplitViewVisibility = .automatic
  @State var isLoading: Bool = false
  
  @State private var showDialog = false
      @State private var progress: Double = 0.0
  
  var body: some View {
    NavigationSplitView(columnVisibility: $isSideBarShow) {
      List(store.repos, id: \.self, selection: $selection2) { (repo: Repo) in
        
          NavigationLink(value: repo) {
            RepoView(repo: repo.repo)
          }
        
      }
//#if canImport(AppKit)
//      .navigationDestination(item: $selection2) { repo in
//        TagsView(repo: repo, selection: $selection, selectedTag: $selectedTag)
//      }
//#endif
#if canImport(UIKit)
      .toolbar {
        toolbar
      }
#endif
    } detail: {
      if let repo = selection2 {
        let tags = (try? repo.repo.allTags().get()) ?? []
        let orderTag: [TagReference] = tags.sorted { lhs, rhs in
          let l = lhs.shortName ?? ""
          let r = rhs.shortName ?? ""
          return compareVersions(l, r)
        }.reversed()
        
        let commitsChildren = try? Paths.commit(repo.repo.user_repo!, "Any")
          .parent()
          .children()
          .map(\.lastComponent)
        var commits: Set<String> = Set(commitsChildren ?? [])
        let latest = (repo.repo.main ?? repo.repo.master)?.oid.description
        if let latest {
          let _ = commits.insert(latest)
        }
        
        TagsView(repo: repo, tags: orderTag, commits: Array(commits), selection: $selection, selectedTag: $selectedTag)
//        TagsView(repo: repo, tags: tags, selection: $selection, selectedTag: $selectedTag)
        //        TagsView(repo: repo.repo)
      } else {
        Text("123")
      }
    }
    .sheet(isPresented: $showDialog) {
        ProgressDialog(progress: $progress)
    }
    .toolbar {
#if canImport(AppKit)
//      if selection2 == nil {
        toolbar
//      }
#endif
    }
//    .onChange(of: selection2, { oldValue, newValue in
//      print(oldValue, newValue)
//      if let newValue {
//        self.store.send(.select(repo: newValue))
//      }
//    })
    .alert("YO!", isPresented: $showAlert) {
      TextField(text: $inputText, prompt: Text("Required")) {
        Text("Repo URL")
      }
      Button("OK") {
        store.send(.addRepo(url: inputText))
      }
      Button("Cancel", role: .cancel) { }
    } message: {
      Text("Please enter your github repo.")
    }
    .onAppear {
      store.send(.repoLoading)
    }
    
  }
  
  //  @ToolbarContentBuilder
  var toolbar: some ToolbarContent {
    ToolbarItemGroup {
      Button(action: {
        showAlert = true
      }) {
        Image(systemName: "plus")
      }
      #if canImport(UIKit)
      Button(action: {
        Task {
          try? await downloadConfig()
        }
      }) {
        Image(systemName: "arrow.clockwise")
      }
      #endif
    }
    
    
      
    
  }
}

//#Preview {
//  DocCListView(store: .init(
//    initialState: DocCListView.Feature.State(repos: []),
//    reducer: {DocCListView.Feature()}
//  ))
//  //  DocCListView()
//  //    .modelContainer(for: DoccItem2.self, inMemory: true)
//}

//        IfLetStore(
//          self.store.scope(
//            state: \.$detail2,
//            action: \.detail
//          )
//        ) {
//          //        TagsView(repo: repo selection: $selection, selectedTag: $selectedTag)
//          TagsView(store: $0)
//            .toolbar {
//#if os(macOS)
//              toolbar
//#endif
//            }
//        } else: {
//          // render a "no data available" view:
//          Text("Empty. Please select an item in the sidebar.")
//        }


func compareVersions(_ version1: String, _ version2: String) -> Bool {
    let components1 = version1.components(separatedBy: ".")
    let components2 = version2.components(separatedBy: ".")
    
    let maxLength = max(components1.count, components2.count)
    
    for i in 0..<maxLength {
        let v1 = i < components1.count ? components1[i] : ""
        let v2 = i < components2.count ? components2[i] : ""
        
        if let num1 = Int(v1), let num2 = Int(v2) {
            if num1 != num2 {
                return num1 < num2
            }
        } else {
            let comparison = v1.compare(v2, options: .numeric)
            if comparison != .orderedSame {
                return comparison == .orderedAscending
            }
        }
    }
    
    return false
}
