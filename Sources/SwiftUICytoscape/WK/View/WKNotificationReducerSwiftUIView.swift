//
//  SwiftUIView.swift
//  
//
//  Created by MEI YIN LO on 2023/10/23.
//

import SwiftUI
import ComposableArchitecture
import WebKit

public struct WKNotificationReducerSwiftUIView: View {
    let store : StoreOf<NotificationReducer<WKScriptMessage>>
    let showColorIndicateViewRefresh : Bool
    public init(store: StoreOf<NotificationReducer<WKScriptMessage>>, showColorIndicateViewRefresh: Bool = false) {
        self.store = store
        self.showColorIndicateViewRefresh = showColorIndicateViewRefresh
    }
    @ViewBuilder
    public var dumpContent : some  View{
        if showColorIndicateViewRefresh{
            Text("showColorIndicateViewRefresh")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(getRandomColor())
        }
        else{
            Circle()
                .frame(width: 1,height: 1)
                .opacity(0)
        }
    }
    public var body: some View {
        WithViewStore(self.store, observe: {$0}) { viewStore in
            dumpContent
                .onAppear{
                    viewStore.send(.listening)
                }
                .onDisappear{
                    viewStore.send(.stopListening)
                }
                .background{
                    
                }
                
        }
        
    }
}
