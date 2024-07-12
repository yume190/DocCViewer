//
//  dup.swift
//  DoccViewer
//
//  Created by Yume on 2024/6/18.
//

import Foundation

class Dup {
  static let shared = Dup()
  private var descriptor: Int32 = 0
  let pipe = Pipe()
  var text: String = ""
  var handler: ((String) -> Void)?
  func enable() {
    descriptor = dup(STDOUT_FILENO)
    dup2(pipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
    startStringStream()
    
  }
  private func startStringStream() {
    pipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
      let data = handle.availableData
      guard let str = String(data: data, encoding: .utf8) else {
        return
      }
      guard let self else {return}
      self.text.append(str)
      self.handler?(self.text)
    }
  }
  
  func disable() {
    dup2(descriptor, STDOUT_FILENO)
  }
}
