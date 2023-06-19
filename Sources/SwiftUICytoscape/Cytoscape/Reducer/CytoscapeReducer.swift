//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/6/16.
//

import Foundation
import ComposableArchitecture

public struct CytoscapeReducer : ReducerProtocol{
    let initGraph : CyGraphData
    let initStyle : [CyStyle]
    let isSelfInitGraph : Bool
    public init(initGraph: CyGraphData = .init(nodes: [], edges: []),
                isSelfInitGraph : Bool = false,
                initStyle : [CyStyle] = CyStyle.defaultStyle
    ) {
        self.initGraph = initGraph
        self.isSelfInitGraph = isSelfInitGraph
        self.initStyle = initStyle
    }
    public struct State: Equatable{
        //public var graph : CyGraphData
        public var wkReducerState : WKReducer.State
        
        public init( wkReducerState: WKReducer.State) {
            //self.graph = graph
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
        case configCytoscape(CyGraphData,[CyStyle])
        case cyAdd(CyGraphData)
        case cyRemove(id: String)
        case cyStyle([CyStyle])
        
        var jsString : String{
            switch self{
            case .configCytoscape(let value, let style):
                return "configCytoscape(\(value.jsonString), \(style.jsonString) );"
            case .cyAdd(let value):
            
                return "cy.add(\(value.jsonString));cy.layout({name:'grid'}).run();"
            case .cyRemove(let id):
                return """
var j = cy.$('#\(id)');
cy.remove( j );
"""
            case .cyStyle(let value):
                return """
cy.style()
.fromJson(\(value.jsonString))
.update();
"""
            }
        }
    }
    public enum Action : Equatable{
        case joinActionWKReducer(WKReducer.Action)
        case configCytoscape(CyGraphData, [CyStyle])
        case queueJS(JavascriptQueue)
        case initGraph
    }
    public var body: some ReducerProtocol<State, Action> {
        Scope(state: \.wkReducerState, action: /Action.joinActionWKReducer, child: {WKReducer()})
        Reduce{state, action in
            switch action{
            case .initGraph:
                if isSelfInitGraph{
                    return .send(.configCytoscape(initGraph, initStyle))
                }
                
            case .queueJS(let value):
                return .send(.joinActionWKReducer(.queueJS(value.jsString)))
            case .configCytoscape(let value, let style):
                //state.graph = value
                return .send(.queueJS(.configCytoscape(value, style)))
                //                return .send(.joinActionWKReducer(.queueJS(JavascriptQueue.configCytoscape(state.graph).jsString)))
            case .joinActionWKReducer(let subAction):
                switch subAction{
                case .receiveMessage(let value, _):
                    let jsEvent = JavascriptEvent.EventName(rawValue: value.name)!.initJavascriptEvent(eventValue: value.body)
                    switch jsEvent{
                    case .DOMContentLoaded:
                        return .send(.initGraph)
                    }
                default:
                    break
                }
            }
            return .none
        }
    }
}
