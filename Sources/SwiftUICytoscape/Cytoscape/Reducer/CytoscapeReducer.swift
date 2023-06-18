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
    public enum JavascriptEvent :  CaseIterable{
        case DOMContentLoaded
        
        
        public enum EventName : String, CaseIterable{
            case DOMContentLoaded
            
            public func initJavascriptEvent(eventValue: Any?)-> JavascriptEvent{
                switch self{
                case .DOMContentLoaded:
                    return JavascriptEvent.DOMContentLoaded
                }
            }
        }
        public var eventName : EventName{
            switch self{
            case .DOMContentLoaded:
                return EventName.DOMContentLoaded
            }
        }
    }
    public enum JavascriptQueue : Equatable {
        case configCytoscape(GraphData)
        case cyAdd(GraphData)
        case cyRemove(id: String)
        
        var jsString : String{
            switch self{
            case .configCytoscape(let value):
                return "configCytoscape(\(value.jsonString));"
            case .cyAdd(let value):
            
                return "cy.add(\(value.jsonString));cy.layout({name:'grid'}).run();"
            case .cyRemove(let id):
                return """
var j = cy.$('#\(id)');
cy.remove( j );
"""
            }
        }
    }
    public enum Action : Equatable{
        case joinActionWKReducer(WKReducer.Action)
        case configCytoscape(GraphData)
        case queueJS(JavascriptQueue)
    }
    public var body: some ReducerProtocol<State, Action> {
        Scope(state: \.wkReducerState, action: /Action.joinActionWKReducer, child: {WKReducer()})
        Reduce{state, action in
            switch action{
            case .queueJS(let value):
                return .send(.joinActionWKReducer(.queueJS(value.jsString)))
            case .configCytoscape(let value):
                state.graph = value
                return .send(.queueJS(.configCytoscape(state.graph)))
                //                return .send(.joinActionWKReducer(.queueJS(JavascriptQueue.configCytoscape(state.graph).jsString)))
            case .joinActionWKReducer(let subAction):
                switch subAction{
                case .receiveMessage(let value):
                    let jsEvent = JavascriptEvent.EventName(rawValue: value.name)!.initJavascriptEvent(eventValue: value.body)
                    switch jsEvent{
                    case .DOMContentLoaded:
                        return .send(.configCytoscape(state.graph))
                    }
                default:
                    break
                }
            }
            return .none
        }
    }
}
