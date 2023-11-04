//
//  SwiftUIView.swift
//  
//
//  Created by MEI YIN LO on 2023/10/24.
//

import SwiftUI
import ComposableArchitecture

public struct CyGraphDataReducerTestView: View {
    let store : StoreOf<CyGraphDataReducer>
    public init(store: StoreOf<CyGraphDataReducer>) {
        self.store = store
    }
    public var body: some View {
        WithViewStore(self.store, observe: {$0}) { viewStore in
            Form{
                Button {
                    //viewStore.send(.clearCanvas)
                    //return .send(.queueJS(.clearCanvas))
                    let id = "\(Int.random(in: 0...1000))"
                    viewStore.send(.addNode(.init(id: id, label: id)))
                   
                } label: {
                    Text("add")
                }
            }
            .background {
                WKNotificationReducerSwiftUIView(store: store.scope(state: \.joinCyCommandReducerState.joinNotificationReducerState, action: {
                    CyGraphDataReducer.Action.joinActionCyCommandReducer(.joinActionNotificationReducer($0))
                    //CyGraphReducer.Action.joinActionNotificationReducer($0)
                    
                }))
            }
        }
    }
}

struct CyGraphDataReducerTestView_Previews: PreviewProvider {
    static var previews: some View {
        VStack{
            CyGraphDataReducerTestView(store: CyGraphDataReducer.store)
            CyWKCoordinatorSwiftUIView()
        }
    }
}
