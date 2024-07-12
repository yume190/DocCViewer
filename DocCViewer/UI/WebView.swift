import SwiftUI
import WebKit

struct WebView {
  let url: URL
}

#if canImport(Cocoa)
extension WebView: NSViewRepresentable {
  func makeNSView(context: Context) -> WKWebView {
    return WKWebView()
  }
  func updateNSView(_ uiView: WKWebView, context: Context) {
    let request = URLRequest(url: url)
    uiView.load(request)
  }
}
#endif

#if canImport(UIKit)
extension WebView: UIViewRepresentable {
  func makeUIView(context: Context) -> WKWebView {
    return WKWebView()
  }
  func updateUIView(_ uiView: WKWebView, context: Context) {
    let request = URLRequest(url: url)
    uiView.load(request)
  }
}

#endif
