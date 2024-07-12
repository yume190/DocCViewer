//
//  DoccViewerApp.swift
//  DoccViewer
//
//  Created by Yume on 2024/6/17.
//

import SwiftUI
import SwiftData
import SwiftDocCUtilities
import SwiftGit2
import SPM


class ServerState: ObservableObject {
  static let shared = ServerState()
    @Published var enable = false
}
class DoccPrebuiltState: ObservableObject {
  static let shared = DoccPrebuiltState()
  @Published var prebuilts: [UserRepo: DoccArchive.Repo] = [:]
}
let api = Github.Assets(config: .init(token: ProcessInfo.processInfo.environment["TOKEN"] ?? ""))

/// repo.json
@MainActor
func downloadConfig() async throws  {
  let assets = try await api.list()
  
  guard let config = assets.filter({ res in
    res.name == "config.json"
  }).first else {
    return
  }
  let (data, _) = try await URLSession.shared.data(from: config.browser_download_url)
  let decoder = JSONDecoder()
  let json = try decoder.decode([UserRepo: DoccArchive.Repo].self, from: data)
  DoccPrebuiltState.shared.prebuilts = json
}

@main
struct DoccViewerApp: App {
  var serverState = ServerState.shared
  var prebuilt = DoccPrebuiltState.shared

  
//  var sharedModelContainer: ModelContainer = {
//    let schema = Schema([
//      DoccItem2.self,
//    ])
//    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
//    
//    do {
//      return try ModelContainer(for: schema, configurations: [modelConfiguration])
//    } catch {
//      fatalError("Could not create ModelContainer: \(error)")
//    }
//  }()
  
  var body: some Scene {
    WindowGroup {
//                  ContentView()
//      DocListView()
      DocCListView(store: .init(
        initialState: DocCListView.Feature.State(repos: []),
        reducer: {DocCListView.Feature()}
      ))
        .environmentObject(serverState)
        .environmentObject(prebuilt)
        .onAppear {
          print("App appear")
          let initRes = SwiftGit2.initialize()
          setenv("DOCC_HTML_DIR", html.string, 1)
          #if canImport(UIKit)
          Task { @MainActor in
            try? await downloadConfig()
          }
          #endif
          
          queue.asyncAfter(deadline: .now() + .milliseconds(2000)) {
            let preview = path + "preview"
            try? preview.mkpath()
            //        previewFolder = preview.isDirectory ? "Directory" : "Not Directory"
            server = try? PreviewServer(contentURL: preview.url, bindTo: .localhost(port: Constants.port), logHandle: &logHandle)
            try? server?.start {
              print("ok")
              serverState.enable = true
              //          isServerOn = true
            }
          }
        }
        .onDisappear {
          print("App disappear")
          try? server?.stop()
          server = nil
          serverState.enable = false
          
        }
    }
//    .modelContainer(sharedModelContainer)
    
  }
}
