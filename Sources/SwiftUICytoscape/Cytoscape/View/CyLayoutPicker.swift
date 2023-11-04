//
//  SwiftUIView.swift
//  
//
//  Created by MEI YIN LO on 2023/11/4.
//

import SwiftUI
import ComposableArchitecture

struct CyLayoutPicker: View {
    let store : StoreOf<CyGraphDataReducer>
    public init(store: StoreOf<CyGraphDataReducer>) {
        self.store = store
    }
    var body: some View {
        WithViewStore(self.store, observe: {$0}) { viewStore in
            Picker(selection:
                    viewStore.binding( get: \.cyGraph.layout,
                                       send: { value in
                CyGraphDataReducer.Action.setLayout(value)
            }))
            {
                ForEach(CyLayout.allCases) { value in
                    Text(value.rawValue)
                        .tag(value)
                }
            } label: {
                Text("layout")
            }
        }
    }
}

