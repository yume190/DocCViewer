//
//  DoccLinkView.swift
//  DocCViewer
//
//  Created by Yume on 2024/7/10.
//

import Foundation
import SwiftUI
import SPM

struct DoccLinkView2: View {
  let name: String
  let tag: String
  let link: DoccArchive.Preview
  @Binding var url: URL?
  @Binding var selection: Bool
  var body: some View {
    
    //    let tagDir = Paths.repo(name, tag)
    VStack(alignment: .leading, spacing: 16) {
      Text("DocC")
        .font(.largeTitle)
        .bold()
        .padding([.top, .leading])
      
      Divider()
      
      VStack(alignment: .leading, spacing: 8) {
        HStack {
          Text("名稱")
            .font(.title2)
            .bold()
          Spacer()
          Text(link.name)
            .font(.title2)
            .bold()
        }
        let document = link.paths.filter {$0.starts(with: "/documentation/")}
        let tutorials = link.paths.filter {$0.starts(with: "/tutorials/")}
        
        list(title: "Ducumentation", paths: document)
        list(title: "Tutorials", paths: tutorials)
      }
    }
    .padding()
  }
  
  @ViewBuilder
  func list(title: String, paths: [String]) -> some View {
    if paths.isEmpty {
      EmptyView()
    } else {
      let tagDir = Paths.tag(name, tag)
      VStack(alignment: .leading, spacing: 10) {
        Text(title)
          .font(.headline)
          .padding([.leading, .top])
        ForEach(paths, id: \.self) { (previewPath: String) in
          let target = tagDir + link.name
          let previewURL = URL(string:"http://localhost:\(Constants.port)\(previewPath)")!
          
          let preview: PathKit.Path = path + "preview"
          let name = (previewPath.split(separator: "/").last.map(String.init) ?? previewPath).firstUppercased()
          HStack {
            Text(name)
            Spacer()
            Image(systemName: "chevron.right")
          }
          .font(.title2)
          .foregroundColor(.white)
          .frame(maxWidth: .infinity)
          .padding()
          .background(Color.blue)
          .cornerRadius(8)
          .padding([.leading, .trailing])
          //          .padding()
          //          .background(Color.cyan)
          //          .contentShape(Rectangle()) // 设置点击区域形状
          .onTapGesture {
            do {
              try preview.delete()
              try preview.symlink(target)
            } catch {
              print(error)
            }
            print("link \(target.string)")
            print("preview \(previewURL)")
            url = previewURL
            selection = true
          }
        }
      }
      .padding()
      .background(Color.gray.opacity(0.2))
      .cornerRadius(10)
      
    }
  }
}
