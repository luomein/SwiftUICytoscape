//
//  SwiftUIView.swift
//  
//
//  Created by MEI YIN LO on 2023/6/15.
//

import SwiftUI
import WebKit

#if os(macOS)
public typealias ViewRepresentable = NSViewRepresentable
#elseif os(iOS)
public typealias ViewRepresentable = UIViewRepresentable
#endif

public struct WKSwiftUIWebView: ViewRepresentable {
    @Environment(\.wkCoordinator) private var coordinator: WKCoordinator
    let eventNames : [String]
    let jsDirectory : String
    let jsLibraryFiles : [String]
    let htmlFileUrl : URL
    public init( eventNames: [String], jsDirectory: String, jsLibraryFiles: [String], htmlFileUrl: URL) {
        self.eventNames = eventNames
        self.jsDirectory = jsDirectory
        self.jsLibraryFiles = jsLibraryFiles
        self.htmlFileUrl = htmlFileUrl
    }
    public func makeNSView(context: Context) -> WKWebView {
        return makeUIView(context: context)
    }
    public func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        
        for jsLibraryFile in jsLibraryFiles {
            let jsLibraryScript = WKCoordinator.loadJSFile(fileName: jsLibraryFile, inDirectory: jsDirectory)
            config.userContentController.addUserScript(jsLibraryScript)
        }
        for eventName in eventNames {
            config.userContentController.add(coordinator, name: eventName)
        }
        
        let _wkwebview = WKWebView(frame: .zero, configuration: config)
        _wkwebview.navigationDelegate = coordinator
        
        return _wkwebview
    }
    public func updateNSView(_ nsView: WKWebView, context: Context) {
        updateUIView(nsView, context: context)
    }
    public func updateUIView(_ uiView: WKWebView, context: Context) {
        
        uiView.loadFileURL(htmlFileUrl,allowingReadAccessTo: htmlFileUrl)

    }
}
