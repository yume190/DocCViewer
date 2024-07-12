//
//  regex.swift
//  DoccViewer
//
//  Created by Yume on 2024/6/18.
//

import Foundation


// Define the URL regex pattern
//let pattern = #"https?://[a-zA-Z0-9\.\-_/]+"#
let pattern = #"https?://[^\s/$.?#].[^\s]*"#


func findUrl(_ input: String) -> [String] {
  do {
    // Create the regular expression
    let regex = try NSRegularExpression(pattern: pattern, options: [])
    
    // Find matches in the string
    let matches = regex.matches(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count))
    
    // Extract the URLs
    let urls = matches.map {
      String(input[Range($0.range, in: input)!])
    }
    
    // Print the extracted URLs
    //      urls.forEach { print($0) }
    return urls
  } catch {
    print("Invalid regex: \(error.localizedDescription)")
    return []
  }
  
}
