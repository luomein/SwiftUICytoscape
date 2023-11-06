//
//  SwiftUIView.swift
//  
//
//  Created by MEI YIN LO on 2023/11/5.
//

import SwiftUI
import ComposableArchitecture
import WebKit

public struct CyWKWrapperView: View {
    let store : StoreOf<NotificationReducer<WKScriptMessage>>
    public init(store: StoreOf<NotificationReducer<WKScriptMessage>>) {
        self.store = store
    }
    public var body: some View {
        CyWKCoordinatorSwiftUIView()
            .background{
                WKNotificationReducerSwiftUIView(store: store)
            }
    }
}


