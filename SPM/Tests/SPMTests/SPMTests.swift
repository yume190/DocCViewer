import XCTest
import Foundation
@testable import SPM

final class SPMTests: XCTestCase {
    func testExample() throws {
      print(#filePath)
      print(#file)
      print(#fileID)
      let path = Path(#file).parent() + "index.json"
      let data = try path.read()
      let decoder = JSONDecoder()
      
      let json = try decoder.decode(DoccArchive.Config.self, from: data)
      print(json)
    }
  
  func testExample3() throws {
    print(#filePath)
    print(#file)
    print(#fileID)
    let file = #file
    let path = Path(file).parent().parent().parent() + "swift-composable-architecture/.build/pointfreeco_swift_composable_architecture/archive/Documentation.doccarchive/index/index.json"
    let data = try path.read()
    let decoder = JSONDecoder()
    
    let json = try decoder.decode(DoccArchive.Config.self, from: data)
    print(json.childrens)
  }
  
  func testExample2() throws {
    print(#filePath)
    print(#file)
    print(#fileID)
    let path = Path(#file).parent() + "index2.json"
    let data = try path.read()
    let decoder = JSONDecoder()
    
    let json = try decoder.decode([DoccArchive.Language].self, from: data)
    print(json)
  }
}
