//
//  SwiftUIView.swift
//  
//
//  Created by MEI YIN LO on 2023/10/23.
//

import SwiftUI
import ComposableArchitecture
import WebKit

struct WKNotificationReducerSwiftUIView: View {
    let store : StoreOf<NotificationReducer<WKScriptMessage>>
    var body: some View {
        WithViewStore(self.store, observe: {$0}) { viewStore in
            //Text("empty")
            Circle()
                .frame(width: 1,height: 1)
                .opacity(0)
                .task {
                    await viewStore.send(.listening).finish()
                }
        }
    }
}
