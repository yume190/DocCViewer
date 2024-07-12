//
//  File.swift
//
//
//  Created by Yume on 2024/6/27.
//

import Foundation
import PathKit

public enum Github {}
extension Github {
  public struct Config {
    let user = "yume190"
    let repo = "TestDoc"
    let releaseId = "162259612"
    let token: String
    
    public init(token: String) {
      self.token = token
    }
    
    var base: String {
      "https://api.github.com/repos/\(user)/\(repo)/releases"
    }
    
    var uploadBase: String {
      "https://uploads.github.com/repos/\(user)/\(repo)/releases"
    }
    
    func setup(request: inout URLRequest) {
      request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
      request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
      request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")
    }
  }
  
  public struct Assets {
    public struct Response: Codable {
      public let id: Int
      public let name: String
      public let browser_download_url: URL
      
    }
    
    let config: Config
    public init(config: Config) {
      self.config = config
    }
    let decoder = JSONDecoder()
    let encoder = {
      let encoder = JSONEncoder()
      encoder.outputFormatting = .withoutEscapingSlashes
      return encoder
    }()
    
    /// https://api.github.com/repos/yume190/TestDoc/dispatches
    public func requestRemoteBuild(repo: String, tag: String) async throws  {
      let url = URL(string: "https://api.github.com/repos/\(config.user)/\(config.repo)/dispatches")!
      var request = URLRequest(url: url)
      request.httpMethod = "POST"
      config.setup(request: &request)
      let json: [String: Any] = [
        "event_type":"build_docc",
        "client_payload":[
          "repo": repo,
          "tag": tag,
          "token": config.token
        ]
      ]
      let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
      request.httpBody = jsonData
      
      let (data, response) = try await URLSession.shared.data(for: request)
      
      guard let httpResponse = response as? HTTPURLResponse else {
        throw URLError(.badServerResponse)
      }
      
      if (200...299).contains(httpResponse.statusCode) {
        print(String(data: data, encoding: .utf8) ?? "")
//        return try decoder.decode([Response].self, from: data)
      } else {
        throw URLError(.badServerResponse)
      }
    }
    
    
    public func list() async throws -> [Response] {
      let url = URL(string: "\(config.base)/\(config.releaseId)/assets")!
      var request = URLRequest(url: url)
      request.httpMethod = "GET"
      //      config.setup(request: &request)
      
      let (data, response) = try await URLSession.shared.data(for: request)
      
      guard let httpResponse = response as? HTTPURLResponse else {
        throw URLError(.badServerResponse)
      }
      
      if (200...299).contains(httpResponse.statusCode) {
        return try decoder.decode([Response].self, from: data)
      } else {
        throw URLError(.badServerResponse)
      }
    }
  }
}


#if canImport(AppKit)
extension Github.Assets {
  public func upload(name: String, file: Path) throws -> Response? {
    let res = try Commands.curl?.addArguments([
      "-L",
      "-X", "POST",
      "-H", "Accept: application/vnd.github+json",
      "-H", "Authorization: Bearer \(config.token)",
      "-H", "X-GitHub-Api-Version: 2022-11-28",
      "-H", "Content-Type: application/octet-stream",
      "\(config.uploadBase)/\(config.releaseId)/assets?name=\(name)",
      "--data-binary", "@\(file.string)"
    ]).waitForOutput().stdout
    
    guard let res else {return nil}
    return try decoder.decode(Response.self, from: Data(res.utf8))
  }
  
  public func upload<JSON: Encodable>(name: String, data: JSON) throws -> Response? {
    guard let json = try String(data: encoder.encode(data), encoding: .utf8) else {
      return nil
    }
    
    let res = try Commands.curl?.addArguments([
      "-L",
      "-X", "POST",
      "-H", "Accept: application/vnd.github+json",
      "-H", "Authorization: Bearer \(config.token)",
      "-H", "X-GitHub-Api-Version: 2022-11-28",
      "-H", "Content-Type: application/octet-stream",
      "\(config.uploadBase)/\(config.releaseId)/assets?name=\(name)",
      "-d", "\(json)"
    ]).waitForOutput().stdout
    guard let res else {return nil}
    return try decoder.decode(Response.self, from: Data(res.utf8))
  }
  
  public func delete(assetId: Int) async throws {
    let url = URL(string: "\(config.base)/assets/\(assetId)")!
    var request = URLRequest(url: url)
    request.httpMethod = "DELETE"
    config.setup(request: &request)
    
    
    let (_, response) = try await URLSession.shared.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse else {
      throw URLError(.badServerResponse)
    }
    
    if (200...299).contains(httpResponse.statusCode) {
      //        return try decoder.decode(Response.self, from: data)
    } else {
      throw URLError(.badServerResponse)
    }
  }
}
#endif
