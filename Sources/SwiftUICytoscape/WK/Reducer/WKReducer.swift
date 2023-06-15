//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/6/15.
//
import Foundation
import ComposableArchitecture
import WebKit


public struct WKReducer : ReducerProtocol{
    
    public struct State: Equatable{
        public init(){}
    }
    public enum Action : Equatable{
        case receiveMessage(WKScriptMessage)
        case queueJS(String)
        
    }
    public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action{
        case .queueJS(let value):
            NotificationCenter.default.post(name: .WKCoordinatorQueueJS, object: value)
        case .receiveMessage(_):
            break
        }
        return .none
    }
}
