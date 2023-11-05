//
//  SwiftUIView.swift
//  
//
//  Created by MEI YIN LO on 2023/6/15.
//

import SwiftUI
import ComposableArchitecture
import WebKit

extension CyTestViewReducer{
    public static var store : StoreOf<Self> = .init(initialState: .init()
                                                         , reducer: {Self()})
}
public struct CyTestViewReducer : Reducer{
    public struct State: Equatable, Hashable{
        var joinCyCommandReducerState : CyCommandReducer.State = .init()
        var joinCyStyleReducerState : CyStyleReducer.State = .nodeStyle
        public init(){}
    }
    public enum Action : Equatable{
        case joinCyCommandReducerAction(CyCommandReducer.Action)
        case joinCyStyleReducerAction(CyStyleReducer.Action)
        case randomAdd(layout: CyLayout)
        case queueJS(CyJsRequest)
    }
    public init(){}
    public var body: some Reducer<State, Action> {
        Scope(state: \.joinCyCommandReducerState, action: /Action.joinCyCommandReducerAction, child: {CyCommandReducer()})
        Scope(state: \.joinCyStyleReducerState, action: /Action.joinCyStyleReducerAction, child: {CyStyleReducer()})
        Reduce{state, action in
            switch action{
            case .randomAdd(let layout):
                let length = 10
                var nodes : [CyNode] = []
                var edges : [CyEdge] = []
                for _ in 1...length {
                    let r = "\(Int.random(in: 0...10000))"
                    nodes.append(.init(id: r, label: r))
                }
                for _ in 1...length{
                    let e = "e\(Int.random(in: 0...10000))"
                    
                    edges.append(.init(id: e, label: e, source: nodes[Int.random(in: 0..<length)].id, target: nodes[Int.random(in: 0..<length)].id))
                }
                return .send(.queueJS(.cyAdd(.init(nodes:nodes, edges:edges, layout:layout))))
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
    @State var layout : CyLayout = .grid
    public init(store: StoreOf<CyTestViewReducer>) {
        self.store = store
    }

   
    public var body: some View {
        WithViewStore(self.store, observe: {$0}) { viewStore in
            Form{
                Picker(selection: .init(get: {layout}, set: {
                    layout = $0
                    viewStore.send(.queueJS(.cyLayout($0)))
                })
                )
                {
                    ForEach(CyLayout.allCases) { value in
                        Text(value.rawValue)
                            .tag(value)
                    }
                } label: {
                    Text("layout")
                }
                
                
                CyStyleReducerView(store: store.scope(state: \.joinCyStyleReducerState, action: {CyTestViewReducer.Action.joinCyStyleReducerAction($0)}))

                
                Button {
                    viewStore.send(.queueJS(.resetCanvas))
                } label: {
                    Text("reset")
                }
                Button {
                    viewStore.send(.randomAdd(layout: layout))
                } label: {
                    Text("add")
                }
                if let cytoscapeJavascriptResponseData = viewStore.state.joinCyCommandReducerState.cytoscapeJavascriptResponseData{
                    Text(cytoscapeJavascriptResponseData.targetId)
                    Text(cytoscapeJavascriptResponseData.eventType.rawValue)
                    Text(cytoscapeJavascriptResponseData.isNode.description)
                }
                
            }

        }
    }
}

struct CytoscapeWKReducerTestView_Previews: PreviewProvider {
    
    
    static var previews: some View {
        VStack{
            CyTestView(store: CyTestViewReducer.store)
            CyWKWrapperView(store: CyTestViewReducer.store.scope(state: \.joinCyCommandReducerState.joinNotificationReducerState
                                               , action: {
                CyTestViewReducer.Action.joinCyCommandReducerAction(.joinActionNotificationReducer($0))
            }))
        }
    }
}
