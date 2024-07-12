//
//  File.swift
//
//
//  Created by Yume on 2024/6/27.
//

import Foundation

public typealias UserRepo = String

public enum DoccArchive {
  public struct Repo: Codable {
    public let url: String
    /// user_repo
    public let name: String
    public let tags: [String: Tag]
    
    public init(url: String, name: String, tags: [String : Tag]) {
      self.url = url
      self.name = name
      self.tags = tags
    }
  }
  
  public struct Tag: Codable {
    public let tag: String
    public let assetId: Int
    /// download url
    public let url: URL
    //    /// docc in spm
    //    public let doccSPM: [Preview]
    //    /// docc not in spm
    //    public let doccWildcard: [Preview]
    
    public init(tag: String, assetId: Int, url: URL) {
      self.tag = tag
      self.assetId = assetId
      self.url = url
    }
  }
  
  public struct Preview: Codable, Hashable {
    /// Guide.docc -> Guide
    public let name: String
    ///
    public let paths: [String]
    
    public init(name: String, paths: [String]) {
      self.name = name
      self.paths = paths
    }
  }
  
  public struct Config: Decodable {
    public let interfaceLanguages: [String: [Language2]]
    
    
    var childrens: [String] {
      let x = interfaceLanguages.values
        .flatMap { $0 }
        .map(\.flat)
        .flatMap { $0 }
      
      let y = x
        .filter { type, _ in
          type == "module" || type == "overview"
        }
        .map(\.path)
          
      return y
    }
  }
  
  public indirect enum Language2: Decodable {
    case item(
      title: String,
      type: String,
      path: String?,
      children: [Language2]?
    )
    
    var flat: [(type: String, path: String )] {
      guard 
        case let.item(_,type,path,children) = self,
        let path
      else  {
        return []
      }
      
    
      let child = children?.flatMap(\.flat) ?? []
      return [(type, path)] + child
      
    }
    
    enum ItemCodingKeys: CodingKey {
      case title
      case type
      case path
      case children
    }
    
    public init(from decoder: any Decoder) throws {
      let container = try decoder.container(keyedBy: DoccArchive.Language2.ItemCodingKeys.self)
      
      self = DoccArchive.Language2.item(
        title: try container.decode(String.self, forKey: DoccArchive.Language2.ItemCodingKeys.title),
        type: try container.decode(String.self, forKey: DoccArchive.Language2.ItemCodingKeys.type),
        path: try container.decodeIfPresent(String.self, forKey: DoccArchive.Language2.ItemCodingKeys.path),
        children: try container.decodeIfPresent([DoccArchive.Language2].self, forKey: DoccArchive.Language2.ItemCodingKeys.children))
      
    }
  }
  
  public struct Language: Decodable {
    public let title: String
    /// module | overview
    public let type: String
    /// "\/documentation\/composablearchitecturemacros"
    /// "\/tutorials\/meetcomposablearchitecture"
    public let path: String?
    public let children: [Children]
  }
  
  public struct Children: Decodable {
    public let title: String
    /// module | overview
    public let type: String
    /// "\/documentation\/composablearchitecturemacros"
    /// "\/tutorials\/meetcomposablearchitecture"
    public let path: String?
    public var noSlashPath: String? {
      path?.replacingOccurrences(of: #"\/"#, with: "/")
    }
  }
}
