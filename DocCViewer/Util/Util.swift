//
//  Logic2.swift
//  DocCViewer
//
//  Created by Yume on 2024/6/27.
//

import Foundation
import SPM
import SWCompression

enum Logic2 {
//  static func downloadZipFile(name: String, tag: String, url: URL) async throws {
//    let zipDir = path + "zip"
//    try zipDir.mkpath()
//    
//    let (data, res) = try await URLSession.shared.data(from: url)
//    let zip = zipDir + "temp.zip"
//    
//    
//    defer { try? zip.delete() }
//    try zip.write(data)
//    
//    let dist = path + name + "tags" + tag
//    try dist.parent().mkpath()
//    try FileManager.default.unzipItem(at: zip.url, to: dist.url)
//  }
  
  static func downloadTarGzFile(name: String, tag: String, url: URL) async throws {
    let tarDir = path + "tar"
    try tarDir.mkpath()
    
    let (data, _) = try await URLSession.shared.data(from: url)
    
    /// un gzip
    let decompressedData = try GzipArchive.unarchive(archive: data)
    
    let dist = Paths.tag(name, tag)
    let tarContainer = try TarContainer.open(container: decompressedData)
    for entry in tarContainer {
      let filePath = dist + entry.info.name
      
      if entry.info.type == .directory {
        try filePath.mkpath()
      } else {
        try filePath.parent().mkpath()
        if let data = entry.data {
          try filePath.write(data)
        }
      }
    }

  }
}


func findGithubUserRepo2(_ url: String) -> (user: String, repo: String)? {
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
  
  let user = String(components[0])
  let repo = String(components[1])
  return (user, repo)
}
