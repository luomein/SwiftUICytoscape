//
//  SwiftUIView.swift
//  
//
//  Created by MEI YIN LO on 2023/11/5.
//

import SwiftUI
import ComposableArchitecture
import WebKit

struct CyWKWrapperView: View {
    let store : StoreOf<NotificationReducer<WKScriptMessage>>
    var body: some View {
        CyWKCoordinatorSwiftUIView()
            .background{
                WKNotificationReducerSwiftUIView(store: store)
            }
    }
}


