//
//  SPMParser.swift
//
//
//  Created by Yume on 2023/1/19.
//

#if canImport(AppKit)
import Basics
import Foundation
import PackageGraph
import PackageModel
import PathKit
import Workspace

// MARK: - SPMParser

public enum SPMParser {
  static let observability = ObservabilitySystem({ print("\($0): \($1)") })
  
  
  public static func graph(path: String) throws -> ModulesGraph {
    let packagePath = try Basics.AbsolutePath(validating: path)
    
    
    let workspace = try Workspace(forRootPackage: packagePath)
    
    return try workspace.loadPackageGraph(rootPath: packagePath, observabilityScope: observability.topScope)
  }
  
  public static func findDocc(path: String) throws -> [(target: String, docc: String)] {
    let graph = try graph(path: path)
    let allPackage = graph.rootPackages
    
    let allTarget = allPackage.flatMap(\.modules)
    return allTarget.compactMap { target in
      let name = target.name
      let docc = target.underlying.others.filter { path in
        path.extension == "docc"
      }.map(\.pathString)
      guard let first = docc.first else {
        return nil
      }
      return (name, first)
    }
  }
}
#endif
