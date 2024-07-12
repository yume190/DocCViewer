//
//  File.swift
//  DocCViewer
//
//  Created by Yume on 2024/7/1.
//

import Foundation
import SwiftUI
import SwiftGit2

class ConfigData: ObservableObject {
//    @Published var username: String = "Guest"
}
//@StateObject
//var config: ConfigData = ConfigData()

//  .environmentObject(userData)



struct RepoView: View {
  
  let repo: Repository
  var body: some View {
    let remote = repo.remote(named: "origin")
    if let remote = try? remote.get(),
       let (user, repo) = findGithubUserRepo2(remote.URL)
        {
      HStack {
        Rectangle()
          .fill(Color.cyan)
          .frame(width: 2)
        VStack(alignment: .leading) {
          Text(user)
            .font(.system(size: 16))
          Text(repo)
            .font(.system(size: 12))
        }
      }
      
    } else {
      EmptyView()
    }
    
  }
}
