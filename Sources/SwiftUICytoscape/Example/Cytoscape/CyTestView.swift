//
//  SwiftUIView.swift
//  
//
//  Created by MEI YIN LO on 2023/6/15.
//

import SwiftUI
import ComposableArchitecture
import WebKit

public struct CyTestViewReducer : ReducerProtocol{
    public struct State: Equatable{
        var joinCyCommandReducerState : CyCommandReducer.State = .init()
        var joinCyStyleReducerState : CyStyleReducer.State = .nodeStyle
        public init(){}
    }
    public enum Action : Equatable{
        case joinCyCommandReducerAction(CyCommandReducer.Action)
        case joinCyStyleReducerAction(CyStyleReducer.Action)
        case queueJS(CyJsRequest)
    }
    public init(){}
    public var body: some ReducerProtocol<State, Action> {
        Scope(state: \.joinCyCommandReducerState, action: /Action.joinCyCommandReducerAction, child: {CyCommandReducer()})
        Scope(state: \.joinCyStyleReducerState, action: /Action.joinCyStyleReducerAction, child: {CyStyleReducer()})
        Reduce{state, action in
            switch action{
            case .joinCyStyleReducerAction(let subAction):
                return .send(.joinCyCommandReducerAction(.queueJS(.cyStyle([state.joinCyStyleReducerState]))))
            case .queueJS(let value):
                return .send(.joinCyCommandReducerAction(.queueJS(value)))
            default:
                break
            }
            return .none
        }
    }
}
public struct CyTestView: View {
    let store : StoreOf<CyTestViewReducer>
    public init(store: StoreOf<CyTestViewReducer>) {
        self.store = store
    }

    
    public var body: some View {
        WithViewStore(self.store, observe: {$0}) { viewStore in
            Form{
                CyStyleReducerView(store: store.scope(state: \.joinCyStyleReducerState, action: {CyTestViewReducer.Action.joinCyStyleReducerAction($0)}))
                Button {
                    //viewStore.send(.clearCanvas)
                    //return .send(.queueJS(.clearCanvas))
                    viewStore.send(.queueJS(.resetCanvas))
                } label: {
                    Text("reset")
                }
                Button {
                    //viewStore.send(.clearCanvas)
                    //return .send(.queueJS(.clearCanvas))
                    viewStore.send(.queueJS(.cyAdd(.init(nodes: [.init( id: "\(Int.random(in: 0...1000))", label: "\(Int.random(in: 0...1000))")  ], edges: []))))
                } label: {
                    Text("add")
                }
                if let cytoscapeJavascriptResponseData = viewStore.state.joinCyCommandReducerState.cytoscapeJavascriptResponseData{
                    Text(cytoscapeJavascriptResponseData.targetId)
                    Text(cytoscapeJavascriptResponseData.eventType.rawValue)
                    Text(cytoscapeJavascriptResponseData.isNode.description)
                }
                
            }
            .background {
                WKNotificationReducerSwiftUIView(store: store.scope(state: \.joinCyCommandReducerState.joinNotificationReducerState, action: {
                    CyTestViewReducer.Action.joinCyCommandReducerAction(.joinActionNotificationReducer($0))
                    //CyGraphReducer.Action.joinActionNotificationReducer($0)
                    
                }))
            }
        }
    }
}

struct CytoscapeWKReducerTestView_Previews: PreviewProvider {
    
    static var store : StoreOf<CyTestViewReducer> = .init(initialState: .init()
                                                         , reducer: {
        
        CyTestViewReducer()
        
        
    })
    static var previews: some View {
        VStack{
            CyTestView(store: store)
            CyWKCoordinatorSwiftUIView()
        }
    }
}
