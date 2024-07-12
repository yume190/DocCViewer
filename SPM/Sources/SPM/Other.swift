//
//  File 2.swift
//  
//
//  Created by Yume on 2024/6/27.
//

import Foundation

public func findGithubUserRepo(_ url: String) -> String? {
  guard let urlComponents = URLComponents(string: url) else {
    return nil
  }
  
  guard let host = urlComponents.host, host == "github.com" else {
    return nil
  }
  
  let path = urlComponents.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
  
  // Remove .git suffix or any other file extension
  let components = path.split(separator: "/")
  guard components.count >= 2 else {
    return nil
  }
  
  let user = components[0]
  var repo = components[1]
  
  if let dotIndex = repo.lastIndex(of: ".") {
    repo = repo.prefix(upTo: dotIndex)
  }
  
  let processedPath = "\(user)_\(repo)".replacingOccurrences(of: "-", with: "_")
  
  return processedPath
}
