//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/6/16.
//

import Foundation
import ComposableArchitecture

public struct CytoscapeReducer : ReducerProtocol{
    public init(){}
    public struct State: Equatable{
        public var graph : GraphData
        public var wkReducerState : WKReducer.State
        
        public init(graph: GraphData, wkReducerState: WKReducer.State) {
            self.graph = graph
            self.wkReducerState = wkReducerState
        }
    }
    public enum JavascriptEvent : String , CaseIterable{
        case DOMContentLoaded
    }
    public enum JavascriptQueue {
        case configCytoscape(GraphData)
        
        var jsString : String{
            switch self{
            case .configCytoscape(let value):
                return "configCytoscape(\(value.jsonString));"
            }
        }
    }
    public enum Action : Equatable{
        case joinActionWKReducer(WKReducer.Action)
        
    }
    public var body: some ReducerProtocol<State, Action> {
        Scope(state: \.wkReducerState, action: /Action.joinActionWKReducer, child: {WKReducer()})
        Reduce{state, action in
            switch action{
            case .joinActionWKReducer(let subAction):
                switch subAction{
                case .receiveMessage(let value):
                    let jsEvent = JavascriptEvent(rawValue: value.name)!
                    switch jsEvent{
                    case .DOMContentLoaded:
                        return .send(.joinActionWKReducer(.queueJS(JavascriptQueue.configCytoscape(state.graph).jsString)))
                    }
                default:
                    break
                }
            }
            return .none
        }
    }
}
