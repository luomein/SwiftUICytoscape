//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/6/15.
//

import Foundation
import WebKit
import SwiftUI


private struct WKCoordinatorEnvironmentKey: EnvironmentKey {
    static let defaultValue = WKCoordinator()
}
public extension EnvironmentValues {
  var wkCoordinator: WKCoordinator {
    get { self[WKCoordinatorEnvironmentKey.self] }
    set { self[WKCoordinatorEnvironmentKey.self] = newValue }
  }
}
public class WKCoordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
    var webView: WKWebView?
    
    public override init() {
        
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.webView = webView
    }
    
    // receive message from wkwebview
    public func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
print(message)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            NotificationCenter.default.post(name: .WKCoordinatorNotification, object: message)
        }
    }
    public func queueJS(js: String){
        print(js)
        self.webView?.evaluateJavaScript(js)
    }
    
    public static func  loadJSFile(fileName: String, inDirectory: String?, injectionTime : WKUserScriptInjectionTime = .atDocumentStart, forMainFrameOnly: Bool = true)->WKUserScript{
        let filepath = Bundle.module.path(forResource: fileName, ofType: "js" )!
        let jsString = try! String(contentsOfFile: filepath)
        return WKUserScript(source: jsString, injectionTime: injectionTime, forMainFrameOnly: forMainFrameOnly)
    }
}
