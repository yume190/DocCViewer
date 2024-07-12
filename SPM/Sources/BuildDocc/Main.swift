//
//  File.swift
//  
//
//  Created by Yume on 2024/6/27.
//

import Foundation
import SPM
import ArgumentParser
import PathKit

let decoder = JSONDecoder()
let encoder = {
  let encoder = JSONEncoder()
  encoder.outputFormatting = .withoutEscapingSlashes
  return encoder
}()


@main
struct DoccCommand: AsyncParsableCommand {
  var config: Github.Config { Github.Config(token: token) }
  var api: Github.Assets { Github.Assets(config: config) }
  
  @Option(name: [.long])
  var repo: String
  
  @Option(name: [.long])
  var path: String = ". "
  
  @Option(name: [.long, .short])
  var tag: String = "Latest"
  
  @Option(name: [.long])
  var token: String
  
  var user_repo: String? {findGithubUserRepo(repo)}
  
  /// findConfig (repo.json)
  /// need continue?
  /// find docc
  /// build docc
  ///   build symbol?
  ///   convert
  ///   archive
  ///   tar gz
  /// upload artifact
  /// update config (repo.json)
  func run() async throws {
    guard let user_repo else { print("");return }
//    exit(1)
    let (config, configAssetId) = try await findConfig()
    if let _ = config[user_repo]?.tags[tag] {
      print("\(user_repo) \(tag) exist")
      return
    }

    let tarGzPath = try await buildDocc()
    do {
      let tarGz = Path(tarGzPath)
      let uploadName = "\(user_repo)_\(tag)_\(tarGz.lastComponent)"
      print("upload \(tarGzPath)")
      guard let assetResponse = try api.upload(name: uploadName, file: tarGz) else { return }
      let tag = DoccArchive.Tag(
        tag: tag,
        assetId: assetResponse.id,
        url: assetResponse.browser_download_url
        
      )
      let newConfig = rebuildConfig(origin: config, tag: tag)
      _ = try await api.delete(assetId: configAssetId)
      _ = try api.upload(name: "config.json", data: newConfig)
    } catch {
      print(error)
    }
  }
  
  func rebuildConfig(origin: [UserRepo: DoccArchive.Repo], tag: DoccArchive.Tag) -> [UserRepo: DoccArchive.Repo] {
    var origin = origin
    if let repo = origin[user_repo!]  {
      var tags = repo.tags
      tags[self.tag] = tag
      origin[user_repo!] = DoccArchive.Repo(
        url: self.repo,
        name: user_repo!,
        tags: tags
      )
      
    } else {
      origin[user_repo!] = DoccArchive.Repo(
        url: self.repo,
        name: user_repo!,
        tags: [self.tag: tag]
      )
    }
    return origin
  }
  
  func buildDocc() async throws ->  String {
    let path = Path.current + self.path
    let action = BuildDocC(name: user_repo!, url: repo, path: path)
    return try action.runGithubAction()
  }
  
  
  /// repo.json
  func findConfig() async throws -> ([UserRepo: DoccArchive.Repo], Int) {
    let assets = try await api.list()
    
    guard let config = assets.filter({ res in
      res.name == "config.json"
    }).first else {
      throw ExitCode(1)
    }
    let (data, _) = try await URLSession.shared.data(from: config.browser_download_url)
    let json = try decoder.decode([UserRepo: DoccArchive.Repo].self, from: data)
    return (json, config.id)
  }
}
