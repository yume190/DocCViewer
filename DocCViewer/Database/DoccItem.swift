import Foundation
import SwiftData

typealias DoccItem = DoccItem2

@Model
final class DoccItem2 {
  var name: String
  var url: URL
  var doccType: DoccType
  /// only use in ``DoccType.github``
  
  var doccs: [DoccWeb]
  
  
  init(name: String, url: URL, doccType: DoccType, doccs: [DoccWeb]) {
    self.name = name
    self.url = url
    self.doccType = doccType
    self.doccs = doccs
  }
}


enum DoccType: Codable {
  case github(user: String, repo: String)
  case md
  case zip
}

struct DoccWeb: Codable, Hashable {
  let name: String
  let doccPath: String
  let previewPaths: [String]
}
