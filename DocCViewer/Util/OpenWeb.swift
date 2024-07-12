//
//  OpenWeb.swift
//  DocCViewer
//
//  Created by Yume on 2024/7/1.
//

#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif

func openWeb(_ url: URL) {
#if canImport(UIKit)
  UIApplication.shared.open(url)
#endif
#if canImport(AppKit)
  NSWorkspace.shared.open(url)
#endif
}
