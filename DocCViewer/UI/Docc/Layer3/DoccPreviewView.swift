//
//  DoccPreview.swift
//  DocCViewer
//
//  Created by Yume on 2024/7/10.
//

import Foundation
import SwiftUI
import SPM

struct DoccPreviewView: View {
  let repo: Repository
  let tag: TagReference
  
  @EnvironmentObject var serverState: ServerState
  
  @State var url: URL?
  @State var selection: Bool = false
  @State var previews: [DoccArchive.Preview] = []
  var body: some View {
    ScrollView {
      VStack {
        
        Text(repo.user_repo ?? "Docc Preview")
          .font(.largeTitle)
          .bold()
          .padding([.top, .leading])
        
        Button("start server") {
          //        if isServerOn {return}
          queue.async {
            let preview = path + "preview"
            try? preview.mkpath()
            //        previewFolder = preview.isDirectory ? "Directory" : "Not Directory"
            server = try? PreviewServer(contentURL: preview.url, bindTo: .localhost(port: Constants.port), logHandle: &logHandle)
            try? server?.start {
              print("ok")
              //          isServerOn = true
            }
          }
        }
        
        ForEach(previews, id: \.self) { (docc) in
          DoccLinkView2(name: repo.user_repo!, tag: tag.name, link: docc, url: $url, selection: $selection)
        }
      }
      .navigationTitle("\(repo.user_repo!)(\(tag.shortName ?? ""))")
#if canImport(UIKit)
      .navigationBarTitleDisplayMode(.inline)
#endif
      .onAppear {
        do {
          let decoder = JSONDecoder()
          let data = try (Paths.tag(repo.user_repo!, tag.name) + "config.json").read()
          previews = try decoder.decode([DoccArchive.Preview].self, from: data)
        } catch {
          
        }
      }
      .navigationDestination(isPresented: $selection) {
        WebView(url: url ?? URL(string: "https://google.com.tw/")!)
          .navigationTitle("\(repo.user_repo!)(\(tag.shortName ?? ""))")
      }
      
    }
    .toolbar {
      ToolbarItemGroup {
        Button(action: {
          if serverState.enable {
            try? server?.stop()
            server = nil
            serverState.enable = false
          } else {
            let preview = path + "preview"
            server = try? PreviewServer(contentURL: preview.url, bindTo: .localhost(port: Constants.port), logHandle: &logHandle)
            try? server?.start {
              print("ok")
              serverState.enable = true
              //          isServerOn = true
            }
          }
        }) {
          HStack {
            Circle()
              .fill(serverState.enable ? Color.green : Color.red)
              .frame(width: 10, height: 10) // Circle with radius 5
            
            if serverState.enable {
              Text("Enabled")
                .foregroundColor(.primary)
                .fontWeight(.light)
            } else {
              Text("Disabled")
                .foregroundColor(.primary)
                .fontWeight(.light)
            }
          }
        }
      }
    }
  }
}
