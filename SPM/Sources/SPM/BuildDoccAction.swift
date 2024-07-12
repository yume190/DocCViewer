//
//  Logic.swift
//  DocCViewer
//
//  Created by Yume on 2024/6/26.
//

import Foundation
import PathKit
import SwiftDocC
import SwiftDocCUtilities

import System

let encoder = {
  let encoder = JSONEncoder()
  encoder.outputFormatting = .withoutEscapingSlashes
  return encoder
}()

public final class BuildDocC {
  /// user_repo
  let name: String
  /// origin repo url
  let url: String
  /// local git path
  let path: Path
  
  /// $repo/.build
  var build: Path { path + ".build" }
  /// $repo/.build/$user_repo
  var x: Path { build + name }
  /// $repo/.build/$user_repo/archive
  var ar: Path { x + "archive" }
  /// $repo/.build/$user_repo/dist
  var dist: Path { x + "dist" }
  
  func symbol(_ target: String) -> Path {
//    path + ".build/symbol/\(target)"
    x + "symbol" + target
  }
  
  public init(name: String, url: String, path: Path) {
    self.name = name
    self.url = url
    self.path = path
  }
  
  
  func findDocc() throws -> (spm: [(target: String, docc: String)], wildcard: Set<String>) {
    let allDocc = path.findAll(fileExteion: "docc", skips: [".build"])
    #if canImport(AppKit)
    let spmDocc = (try? SPMParser.findDocc(path: path.string + "/")) ?? []
    #else
    let spmDocc: [(target: String, docc: String)] = []
    #endif
    let allSet: Set<String> = Set(allDocc.map(\.string))
    let spmSet: Set<String> = Set(spmDocc.map(\.docc)/*.flatMap { $0 }*/)
    let wildcardDocc: Set<String> = allSet.subtracting(spmSet)
    return (spmDocc, wildcardDocc)
  }
  
  func buildSpm(inputs: [(target: String, docc: Path)]) throws -> [DoccArchive.Preview] {
#if canImport(AppKit)
    var result: [DoccArchive.Preview] = []
    try inputs.forEach { (target, docc) in
      try resetSwiftPM()
      try buildSymbol(target: target)
      let previewPath = try convert(docc, target)
      try self.archive(docc)
      print("build spm over \(target) \(previewPath)")
      result.append(DoccArchive.Preview(
        name: docc.lastComponentWithoutExtension,
        paths: previewPath
      ))
    }
    return result
#else
    return []
#endif
  }
  
  func buildWildcard(inputs: [Path]) throws -> [DoccArchive.Preview] {
    var result: [DoccArchive.Preview] = []
    try inputs.forEach { (docc) in
      let previewPath = try convert(docc, nil)
      try self.archive(docc)
      print("buildWildcard over \(previewPath)")
      result.append(DoccArchive.Preview(
        name: docc.lastComponentWithoutExtension,
        paths: previewPath
      ))
    }
    return result
  }
  
  func convert(_ docc: Path, _ target: String?) throws -> [String] {
    print("convert \(docc.string)")
    
    let doccName = docc.lastComponentWithoutExtension
    let doccarchive = self.ar + "\(doccName).doccarchive"
    try doccarchive.parent().mkpath()
    
    let cmd: Docc.Convert
    if let target {
#if canImport(AppKit)
      try Commands.docc?.addArguments([
          "convert",
          "--additional-symbol-graph-dir", symbol(target).string,
          "--fallback-bundle-identifier", target,
          "--transform-for-static-hosting",
          "--output-path", doccarchive.string,
          docc.string,
      ]).wait()

      let indexJson = doccarchive + "index" + "index.json"
      if indexJson.exists {
        let data = try indexJson.read()
        let decoder = JSONDecoder()
        
        let json = try decoder.decode(DoccArchive.Config.self, from: data)
        return json.childrens
      } else {
        return []
      }
#else
      return []
#endif
    } else {
#if canImport(AppKit)
      try Commands.docc?.addArguments([
          "convert",
          "--output-path", doccarchive.string,
          docc.string,
      ]).wait()
      let indexJson = doccarchive + "index" + "index.json"
      if indexJson.exists {
        let data = try indexJson.read()
        let decoder = JSONDecoder()
        
        let json = try decoder.decode(DoccArchive.Config.self, from: data)
        return json.childrens
      } else {
        return []
      }
#else
      cmd = try Docc.Convert.parse([
        "--output-path", doccarchive.string,
        docc.string,
      ])
      var convertAction = try ConvertAction(fromConvertCommand: cmd)
      try convertAction.performAndHandleResult()
      return try convertAction.context.previewPaths()
#endif
    }
    
  }
  
  func archive(_ docc: PathKit.Path) throws {
    print("\(#function) \(docc.string)")
    
    let doccName = docc.lastComponentWithoutExtension
    let doccarchive = self.ar + "\(doccName).doccarchive"
    let dist = self.dist + doccName
    try dist.parent().mkpath()
    
    let args = [
      "process-archive", "transform-for-static-hosting", doccarchive.string,
      "--output-path", dist.string,
    ]
#if canImport(AppKit)
    try Commands.docc?.addArguments(args).wait()
#else
    var cmd = try Docc.parseAsRoot(args)
    try cmd.run()
#endif
    
  }
}

#if canImport(AppKit)
extension BuildDocC {
  public func runMac(commit: String) throws {
    /// Build DocC
    let (spm, wildcard) = try findDocc()
    let wildcardDocc = try buildWildcard(inputs: wildcard.map { Path($0) } )
    let spmDocc = try buildSpm(inputs: spm.map { ($0, Path($1)) })
    
    let destination = Paths.commit(name, commit)
    
    /// move htmls to .../dist/$user_repo/commits/$commit
    let chilren = try dist.children()
    try destination.mkpath()
    for dir in chilren {
      try dir.move(destination + dir.lastComponent)
    }
    
    try createConfig(destination: destination, docc: spmDocc + wildcardDocc)
  }
  
  public func runMac(tag: String) throws {
    /// Build DocC
    let (spm, wildcard) = try findDocc()
    let wildcardDocc = try buildWildcard(inputs: wildcard.map { Path($0) } )
    let spmDocc = try buildSpm(inputs: spm.map { ($0, Path($1)) })
    
    let destination = Paths.tag(name, tag)
    
    /// move htmls to .../dist/$user_repo/tags/$tag
    let chilren = try dist.children()
    try destination.mkpath()
    for dir in chilren {
      try dir.move(destination + dir.lastComponent)
    }
    
    try createConfig(destination: destination, docc: spmDocc + wildcardDocc)
  }
  
  /// url: origin repo url
  /// target: path that the repo download
  public func runGithubAction() throws -> String {
    try setupEnv()
//    setenv("DOCC_EXTRACT_EXTENSION_SYMBOLS", "NO", 1)
    
    /// Build DocC
    let (spm, wildcard) = try findDocc()
    let wildcardDocc = try buildWildcard(inputs: wildcard.map { Path($0) } )
    let spmDocc = try buildSpm(inputs: spm.map { ($0, Path($1)) })
    
    let destination = dist
    try createConfig(destination: destination, docc: spmDocc + wildcardDocc)
    
    try tarGz()
    return "\(dist.string).tar.gz"
  }
  
  func createConfig(destination: Path, docc: [DoccArchive.Preview]) throws {
    let data = try encoder.encode(docc)
    try (destination + "config.json").write(data)
  }
  
  /// tar zcvf dist.tar.gz dist
  /// to
  /// tar zcvf dist.tar.gz -C dist .
  func tarGz() throws {
    _ = try Commands.tar?
      .setCWD(.init(dist.parent().string))
      .addArguments([
        "zcvf", "\(dist.lastComponent).tar.gz", "-C", "\(dist.lastComponent)", "."
      ]).waitForOutput()
  }
  
  /// zip -r dist.zip dist
  func zip() throws {
    print("zip", "-r", "\(dist.lastComponent).zip", "\(dist.lastComponent)")
    _ = try Commands.zip?
      .setCWD(.init(dist.parent().string))
      .addArguments([
        "-r", "\(dist.lastComponent).zip", "\(dist.lastComponent)"
      ]).waitForOutput()
  }
  
  /// export DOCC_HTML_DIR="$(dirname $(xcrun --find docc))/../share/docc/render"
  func setupEnv() throws {
    let output = try Commands.xcrun?.addArguments([
      "--find", "docc",
    ]).waitForOutput()
    guard let doccPath = output?.stdout else {
      return
    }
    let output2 = try Commands.dirname?.addArgument(doccPath).waitForOutput()
    guard let htmlPath = output2?.stdout else {
      return
    }
    
    setenv(
      "DOCC_HTML_DIR",
      htmlPath.replacingOccurrences(of: "\n", with: "") + "/../share/docc/render",
      1
    )
    //    getenv("DOCC_HTML_DIR")
  }
  
  func resetSwiftPM() throws {
    _ = try Commands.swift?.addArguments([
      "package", "reset",
    ]).waitForOutput()
  }
  
  func buildSymbol(target: String) throws {
    _ = try Commands.swift?.addArguments([
      "build",
      "--package-path", "\(path.string)",
      "--target", "\(target)",
      "-Xswiftc", "-emit-symbol-graph",
      "-Xswiftc", "-emit-symbol-graph-dir",
      "-Xswiftc", "\(symbol(target).string)",
    ]).waitForOutput()
  }
}
#endif



