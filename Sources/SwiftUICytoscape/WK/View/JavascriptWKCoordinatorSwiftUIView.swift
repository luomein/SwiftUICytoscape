//
//  SwiftUIView.swift
//  
//
//  Created by MEI YIN LO on 2023/10/21.
//

import SwiftUI
import WebKit

#if os(macOS)
public typealias ViewRepresentable = NSViewRepresentable
#elseif os(iOS)
public typealias ViewRepresentable = UIViewRepresentable
#endif



class JavascriptWKCoordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler, Identifiable {
    var webView: WKWebView?
    var id: String
    var fromWKCoordinatorNotification : Notification.Name
    init( id: String, fromWKCoordinatorNotification: Notification.Name) {
        self.id = id
        self.fromWKCoordinatorNotification = fromWKCoordinatorNotification
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.webView = webView
    }
    
    // receive message from wkwebview
    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            NotificationCenter.default.post(name: self.fromWKCoordinatorNotification, object: message, userInfo: ["id": self.id])
        }
    }
    func evaluateJavaScript(js: String){
        self.webView?.evaluateJavaScript(js, completionHandler: nil)
    }
}

struct JavascriptWKCoordinatorWebView: ViewRepresentable {
    unowned private var coordinator: JavascriptWKCoordinator
    let eventNames : [String]
    let htmlFileUrl : URL
    let jsFiles : [URL]
    init(coordinator: JavascriptWKCoordinator,
                eventNames: [String]   ,
                htmlFileUrl: URL  ,
                jsFiles: [URL] = []
    ) {
        self.coordinator = coordinator
        self.eventNames = eventNames
        self.htmlFileUrl = htmlFileUrl
        self.jsFiles = jsFiles
    }
    func makeNSView(context: Context) -> WKWebView {
        return makeUIView(context: context)
    }
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        for jsFile in jsFiles {
            let jsString = try! String(contentsOf: jsFile)
            let wkUserScript = WKUserScript(source: jsString, injectionTime: .atDocumentStart, forMainFrameOnly: true)
            config.userContentController.addUserScript(wkUserScript)
        }
        for eventName in eventNames {
            config.userContentController.add(coordinator, name: eventName)
        }
        let _wkwebview = WKWebView(frame: .zero, configuration: config)
        _wkwebview.navigationDelegate = coordinator
        if #available(macOS 13.3, iOS 16.4, tvOS 16.4, *) {
            _wkwebview.isInspectable = true
            //https://webkit.org/blog/13936/enabling-the-inspection-of-web-content-in-apps/
        }
        return _wkwebview
    }
    func updateNSView(_ nsView: WKWebView, context: Context) {
        updateUIView(nsView, context: context)
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadFileURL(htmlFileUrl,allowingReadAccessTo: htmlFileUrl)
    }
}

public struct JavascriptWKCoordinatorSwiftUIView: View {
    private var coordinator: JavascriptWKCoordinator
    private var javascriptWKCoordinatorWebView : JavascriptWKCoordinatorWebView
    private var fromWKCoordinatorNotification : Notification.Name
    private var toWKCoordinatorNotification : Notification.Name
    public init(coordinatorID : String ,
                eventNames: [String]  ,
                htmlFileUrl: URL  ,
                jsFiles: [URL] ,
                fromWKCoordinatorNotification: Notification.Name ,
                toWKCoordinatorNotification: Notification.Name
    ) {
        self.fromWKCoordinatorNotification = fromWKCoordinatorNotification
        self.toWKCoordinatorNotification = toWKCoordinatorNotification
        self.coordinator = .init(id: coordinatorID, fromWKCoordinatorNotification: fromWKCoordinatorNotification)
        self.javascriptWKCoordinatorWebView = JavascriptWKCoordinatorWebView.init(coordinator: self.coordinator
                                                                                  , eventNames: eventNames
                                                                                  , htmlFileUrl: htmlFileUrl
                                                                                  , jsFiles: jsFiles)
    }
    public var body: some View {
        javascriptWKCoordinatorWebView
        .onReceive(NotificationCenter.default.publisher(for: toWKCoordinatorNotification)) {
            if let coordinatorID = $0.userInfo?["id"] as? String, coordinatorID == coordinator.id{
                let jsString =  ($0.object  as! String )
                coordinator.evaluateJavaScript(js: jsString)
            }
        }
    }
}

