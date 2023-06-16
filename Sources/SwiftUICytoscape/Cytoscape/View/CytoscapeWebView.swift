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
    @ViewBuilder
    public var wkListenerView : some View{
        Group{
            WKListenWKCoordinatorNotificationView(store: store.scope(state: \.wkReducerState, action: CytoscapeReducer.Action.joinActionWKReducer))
            WKListenQueueJSView()
        }
    }
    public var wkSwiftUIWebView : WKSwiftUIWebView{
        
        let htmlFileUrl = Bundle.module.url(forResource: "index", withExtension: "html")!
        let eventNames = CytoscapeReducer.JavascriptEvent.EventName.allCases.map({$0.rawValue})
        return WKSwiftUIWebView(eventNames: eventNames, jsDirectory: "Javascript", jsLibraryFiles: ["cytoscape.min","cytoscape.event"], htmlFileUrl: htmlFileUrl)
    }
    public var body: some View {
        Group{
            wkListenerView
            wkSwiftUIWebView
            
//            WithViewStore(self.store, observe: {$0}) { viewStore in
//                Button {
//                    viewStore.send(.queueJS(.cyAdd))
//                } label: {
//                    Text("test")
//                }
//
//            }
        }
    }
}

