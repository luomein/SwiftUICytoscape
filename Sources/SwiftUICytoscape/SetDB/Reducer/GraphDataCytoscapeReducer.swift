//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/10/9.
//

import Foundation
import ComposableArchitecture


public struct GraphDataCytoscapeReducer : ReducerProtocol{

    public init() {}
    public struct State: Equatable{
        public var cytoscapeWKReducerState : CyCommandReducer.State = .init()
        public var graph : SetDBGraphData = SetDBGraphData.emptyGraph
        public var graphStyle : IdentifiedArrayOf<CyStyle> = IdentifiedArray(uniqueElements:  CyStyle.defaultStyle )
        public var selectedFromNode : SetDBNode?
        public var selectedToNode : SetDBNode?
        public var selectMode : selectMode = .none
        public enum selectMode{
            case fromNode
            case toNode
            case none
        }
        public init() {
          
           
        }
    }
    
    
    public enum Action : Equatable{
        
        case joinActionCytoscapeWKReducer(CyCommandReducer.Action)
        case joinActionGraphStyleReducer(CyStyleReducer.State.ID,CyStyleReducer.Action)
        case addNode(CyNode)
        case addEdge(CyEdge)
        case updateSelectMode(State.selectMode)
    }
    public var body: some ReducerProtocol<State, Action> {
        Scope(state: \.cytoscapeWKReducerState, action: /Action.joinActionCytoscapeWKReducer, child: {CyCommandReducer()})
        Reduce{state, action in
            switch action{
            case .joinActionGraphStyleReducer:
                return .send(.joinActionCytoscapeWKReducer(.queueJS(.cyStyle(state.graphStyle.elements))))
            case .updateSelectMode(let value):
                state.selectMode = (state.selectMode == value) ? .none : value
                switch state.selectMode{
                case .fromNode:
                    state.selectedFromNode = nil
                case .toNode:
                    state.selectedToNode = nil
                case .none:
                    switch value{
                    case .fromNode:
                        state.selectedFromNode = nil
                    case .toNode:
                        state.selectedToNode = nil
                    default:
                        break
                    }
                }
            case .addNode(let data):
                fatalError()
//                state.graph.nodes.append(data)
//                return .send(.joinActionCytoscapeWKReducer(.queueJS(.cyAdd(.init(nodes: [data], edges: []) ) ) ))
            case .addEdge(let data):
                fatalError()
//                state.graph.edges.append(data)
//                return .send(.joinActionCytoscapeWKReducer(.queueJS(.cyAdd(.init(nodes: [], edges: [data]) ) ) ))
//
            case .joinActionCytoscapeWKReducer(let subAction):
                switch subAction{
                case .cytoscapeEvent(let responseData):
                    switch responseData.eventType{
                    case .click, .tap:
                        if responseData.isNode{
                            let selectedNode = state.graph.nodes.first {
                                $0.id == responseData.targetId
                            }!
                            switch state.selectMode{
                            case .fromNode:
                                state.selectedFromNode = selectedNode
                            case .toNode:
                                state.selectedToNode = selectedNode
                            default:
                                break
                            }
                        }
                    }
                default:
                    break
                }
            }
            return .none
        }
        .forEach(\.graphStyle, action: /Action.joinActionGraphStyleReducer, element: {CyStyleReducer()})
    }
}

