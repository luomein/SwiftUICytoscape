//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/6/16.
//

import Foundation
import ComposableArchitecture
import WebKit



public struct CyCommandReducer : Reducer{
    enum wkCoordinatorID : String {
        case defaultValue
    }
    let initGraph : CyGraph
    let initStyle : [CyStyle]
    public init(initGraph : CyGraph = .emptyGraph, initStyle : [CyStyle] =  CyStyle.defaultStyle) {
        self.initGraph = initGraph
        self.initStyle = initStyle
    }
    public struct State: Equatable, Hashable{
        public var cytoscapeJavascriptResponseData :CyJsResponse.CyJsResponseData?
        public var joinNotificationReducerState : NotificationReducer<WKScriptMessage>.State = .init()
        public var isDOMContentLoaded : Bool = false
        public init(  ) {
            
        }
    }
    
    
    public enum Action : Equatable{
        
        case joinActionNotificationReducer(NotificationReducer<WKScriptMessage>.Action)
        case cytoscapeEvent(CyJsResponse.CyJsResponseData)
        case queueJS(CyJsRequest)
        
    }
    public var body: some Reducer<State, Action> {
        Scope(state: \.joinNotificationReducerState, action: /Action.joinActionNotificationReducer, child: {NotificationReducer<WKScriptMessage>(listenNotificationName: .fromCyWKCoordinatorNotification, postNotificationName: .toCyWKCoordinatorNotification, coordinatorID: wkCoordinatorID.defaultValue.rawValue)})
        Reduce{state, action in
            switch action{
            case .queueJS(let value):
                assert(state.isDOMContentLoaded)
                assert(state.joinNotificationReducerState.isListening)
                print(value.jsString)
                return .send(.joinActionNotificationReducer(.postNotification(value.jsString)))
            case .cytoscapeEvent:
                break
            case .joinActionNotificationReducer(let subAction):
                switch subAction{
                case .receive(let value):
                    let jsEvent = CyJsResponse(rawValue: value.name)!
                    let eventValue = value.body
                    //print(eventValue)
                    switch jsEvent{
                    case .DOMContentLoaded:
                        state.isDOMContentLoaded = true
                        
                        return    .send(.queueJS(.initCytoscape(self.initGraph , self.initStyle)))
                        
                    case .CytoscapeEvent:
                        state.cytoscapeJavascriptResponseData = jsonObjectFromJS(json:   eventValue )
                        return .send(.cytoscapeEvent(state.cytoscapeJavascriptResponseData!) )
                    }
                default:
                    break
                }
            }
            return .none
        }
    }
}
