//
//  SwiftUIView.swift
//  
//
//  Created by MEI YIN LO on 2023/6/15.
//

import SwiftUI
import ComposableArchitecture

public struct CytoscapeWebView: View {
    let store : StoreOf<CytoscapeReducer>
    public init(store: StoreOf<CytoscapeReducer>) {
        self.store = store
    }
    public var wkSwiftUIWebView : WKSwiftUIWebView{
        
        let htmlFileUrl = Bundle.module.url(forResource: "index", withExtension: "html")!
        let eventNames = CytoscapeReducer.JavascriptEvent.allCases.map({$0.rawValue})
        return WKSwiftUIWebView(eventNames: eventNames, jsDirectory: "Javascript", jsLibraryFiles: ["cytoscape.min","cytoscape.event"], htmlFileUrl: htmlFileUrl)
    }
    public var body: some View {
        Group{
            WKListenWKCoordinatorNotificationView(store: store.scope(state: \.wkReducerState, action: CytoscapeReducer.Action.joinActionWKReducer))
            wkSwiftUIWebView
            WKListenQueueJSView()
//            WithViewStore(self.store, observe: {$0}) { viewStore in
//                Button {
//                    viewStore.send(.joinActionWKReducer(.queueJS(CytoscapeReducer.JavascriptQueue.configCytoscape(viewStore.state.graph).jsString)))
//                } label: {
//                    Text("test")
//                }
//
//            }
        }
    }
}

