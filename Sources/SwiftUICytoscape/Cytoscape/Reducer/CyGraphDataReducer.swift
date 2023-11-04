//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/10/24.
//

import Foundation
import ComposableArchitecture

public struct CyGraphDataReducer : Reducer{
    let initGraph : CyGraph
    let initStyle : [CyStyle]
    public init(initGraph: CyGraph, initStyle: [CyStyle]) {
        self.initGraph = initGraph
        self.initStyle = initStyle
    }
    public struct State: Equatable{
        public var joinCyCommandReducerState : CyCommandReducer.State = .init()
        public var joinCyStyleReducerState : IdentifiedArrayOf<CyStyle>
        public var cyGraph : CyGraph
        public init(joinCyCommandReducerState: CyCommandReducer.State, joinCyStyleReducerState: IdentifiedArrayOf<CyStyle>, cyGraph: CyGraph) {
            self.joinCyCommandReducerState = joinCyCommandReducerState
            self.joinCyStyleReducerState = joinCyStyleReducerState
            self.cyGraph = cyGraph
        }
    }
    public enum Action : Equatable{
        case joinActionCyCommandReducer(CyCommandReducer.Action)
        case joinActionCyStyleReducer(CyStyleReducer.State.ID,CyStyleReducer.Action)
        case addNode(CyNode)
        case addEdge(CyEdge)
        case setLayout(CyLayout)
        case update(CyGraph)
        //case addEdge(CyEdge)
    }
    public var body: some Reducer<State, Action> {
        Scope(state: \.joinCyCommandReducerState, action: /Action.joinActionCyCommandReducer, child: {CyCommandReducer(initGraph: initGraph, initStyle: initStyle)})
        
        Reduce{state, action in
            switch action{
            case .setLayout(let layout):
                state.cyGraph.layout = layout
                return .send(.joinActionCyCommandReducer(.queueJS(.cyLayout(layout) ) ))
            case .addEdge(let data):
                guard state.cyGraph.edges.first(where: {$0.id == data.id}) == nil else{break}
                state.cyGraph.edges.append(data)
                return .send(.joinActionCyCommandReducer(.queueJS(.cyAdd(.init(nodes: [], edges: [data] , layout: state.cyGraph.layout) ) ) ))
            case .addNode(let data):
                guard state.cyGraph.nodes.first(where: {$0.id == data.id}) == nil else{break}
                state.cyGraph.nodes.append(data)
                return .send(.joinActionCyCommandReducer(.queueJS(.cyAdd(.init(nodes: [data], edges: [] , layout: state.cyGraph.layout) ) ) ))
            case .update(let newGraph):
                let newNodes = newGraph.nodes.filter{newGraphNode in
                    state.cyGraph.nodes.first { currentGraphNode in
                        currentGraphNode.id == newGraphNode.id
                    } == nil
                }
                let newEdges = newGraph.edges.filter{newGraphEdge in
                    state.cyGraph.edges.first { currentGraphEdge in
                        currentGraphEdge.id == newGraphEdge.id
                    } == nil
                }
                let deletedNodes = state.cyGraph.nodes.filter{currentGraphNode in
                    newGraph.nodes.first {newGraphNode  in
                        currentGraphNode.id == newGraphNode.id
                    } == nil
                }
                let deletedEdges = state.cyGraph.edges.filter{currentGraphEdge in
                    newGraph.edges.first { newGraphEdge in
                        currentGraphEdge.id == newGraphEdge.id
                    } == nil
                }
                let removeClassNodes = state.cyGraph.nodes.filter{currentGraphNode in
                    if let newGraphNode = newGraph.nodes.first(where: { newGraphNode in
                        currentGraphNode.id == newGraphNode.id
                    }){
                        if(currentGraphNode.classes ?? []) != (newGraphNode.classes ?? []){
                            return !(currentGraphNode.classes ?? []).isEmpty
                        }
                    }
                    return false
                }
                let addClassNodes = newGraph.nodes.filter{newGraphNode in
                    if let existingNode = state.cyGraph.nodes.first(where: { currentGraphNode in
                        currentGraphNode.id == newGraphNode.id
                    }){
                        if(existingNode.classes ?? []) != (newGraphNode.classes ?? []){
                            return !(newGraphNode.classes ?? []).isEmpty
                        }
                    }
                    return false
                }
                let updatedLayout : [CyLayout] = (state.cyGraph.layout != newGraph.layout) ? [newGraph.layout] :  []
                
                state.cyGraph = newGraph
                return .concatenate(
                    .send(.joinActionCyCommandReducer(.queueJS(.cyAdd(.init(nodes: newNodes, edges: newEdges , layout: state.cyGraph.layout) ) ) ))
                    ,
                    .concatenate(updatedLayout.map({
                        .send(.joinActionCyCommandReducer(.queueJS(.cyLayout($0))))
                    }))
                    ,
                    .concatenate(
                        removeClassNodes.flatMap({node in
                            node.classes!.map({
                                .send(.joinActionCyCommandReducer(.queueJS(.cyRemoveClass(id: node.id, class: $0) ) ))
                            })
                            
                        })
                    )
                    ,
                    .concatenate(
                        addClassNodes.flatMap({node in
                            node.classes!.map({
                                .send(.joinActionCyCommandReducer(.queueJS(.cyAddClass(id: node.id, class: $0) ) ))
                            })
                            
                        })
                    )
                    ,
                    .concatenate(
                        deletedNodes.map({
                            .send(.joinActionCyCommandReducer(.queueJS(.cyRemove(id: $0.id) ) ))
                        })
                    )
                    ,
                    .concatenate(
                        deletedEdges.map({
                            .send(.joinActionCyCommandReducer(.queueJS(.cyRemove(id: $0.id) ) ))
                        })
                    )
                )
            default:
                break
            }
            return .none
        }
        .forEach(\.joinCyStyleReducerState, action: /Action.joinActionCyStyleReducer, element: {CyStyleReducer()})
    }
}

public extension CyGraphDataReducer{
    static var store : StoreOf<CyGraphDataReducer> = .init(initialState: .init(joinCyCommandReducerState: .init()
                                                                             , joinCyStyleReducerState: IdentifiedArray(uniqueElements: CyStyle.defaultStyle)
                                                                             ,cyGraph: .emptyGraph)
                                                         , reducer: {
        
        CyGraphDataReducer(initGraph: .emptyGraph, initStyle: CyStyle.defaultStyle)
        
        
    })
}
