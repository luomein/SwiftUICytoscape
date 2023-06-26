//
//  SwiftUIView.swift
//  
//
//  Created by MEI YIN LO on 2023/10/9.
//

import SwiftUI
import ComposableArchitecture

public struct GraphDataCytoscapeReducerView: View {
    let store : StoreOf<GraphDataCytoscapeReducer>
    //let wkCoordinator : WKCoordinator
    
    public init(store: StoreOf<GraphDataCytoscapeReducer>) {
        self.store = store
        
    }
    public var body: some View {
//        WithViewStore(self.store, observe: {$0}) { viewStore in
//            VStack{
//                CytoscapeWKReducerView(store: store.scope(state: \.cytoscapeWKReducerState, action: {GraphDataCytoscapeReducer.Action.joinActionCytoscapeWKReducer($0)}))
//            }
//        }
        WKNotificationReducerSwiftUIView(store: store.scope(state: \.cytoscapeWKReducerState.joinNotificationReducerState, action: {
            GraphDataCytoscapeReducer.Action.joinActionCytoscapeWKReducer(
                CyCommandReducer.Action.joinActionNotificationReducer($0)
            )
            
            
        }))
        
    }
}
public struct GraphDataCytoscapeReducerTestView: View {
    let store : StoreOf<GraphDataCytoscapeReducer>
    //let wkCoordinator : WKCoordinator
    
    public init(store: StoreOf<GraphDataCytoscapeReducer>) {
        self.store = store
        
    }
    public var body: some View {
        WithViewStore(self.store, observe: {$0}) { viewStore in
            VStack{
//                Button {
//                    let newNode : SetDBNode = .init(data:  .init(id: "\(Int.random(in: 0...1000))", label: "\(Int.random(in: 0...1000))") )
//                    viewStore.send(.addNode(newNode))
//                } label: {
//                    Text("add node")
//                }
                HStack{
                    Button {
                        viewStore.send(.updateSelectMode(.fromNode))
                    } label: {
                        Text( viewStore.selectedFromNode?.data.label ?? "from node")
                            .foregroundColor( (viewStore.selectMode == .fromNode) ? .red : nil )
                    }
                    Button {
                        viewStore.send(.updateSelectMode(.toNode))
                    } label: {
                        Text(viewStore.selectedToNode?.data.label ?? "to node")
                            .foregroundColor( (viewStore.selectMode == .toNode) ? .red : nil )
                    }
//                    Button {
//                        if let selectedFromNode = viewStore.selectedFromNode, let selectedToNode = viewStore.selectedToNode{
//                            let newEdge : SetDBEdge = .init(data: .init(id: UUID().uuidString, source: selectedFromNode.id, target: selectedToNode.id))
//                            viewStore.send(.addEdge(newEdge))
//                        }
//                    } label: {
//                        Text("add edge")
//                            .disabled(viewStore.selectedToNode == nil || viewStore.selectedFromNode == nil)
//                    }
                }
                GraphDataCytoscapeReducerView(store: store)
            }
        }
    }
}

struct GraphDataCytoscapeReducerTestView_Previews: PreviewProvider {
    static var store : StoreOf<GraphDataCytoscapeReducer> = .init(initialState: .init()
                                                         , reducer: {
        
        GraphDataCytoscapeReducer()
        
        
    })
    static var previews: some View {
        
        VStack{
            GraphDataCytoscapeReducerTestView(store: store)
            CyWKCoordinatorSwiftUIView()
        }
    }
}
