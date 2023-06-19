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
        var wkCoordinatorID: UUID?
        public init() {
           print("WKReducer State Init")
        }
    }
    public enum Action : Equatable{
        case receiveMessage(WKScriptMessage,UUID)
        case queueJS(String)
        case setCoordinatorID(UUID)
    }
    public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action{
        case .setCoordinatorID(let value):
            state.wkCoordinatorID = value
        case .queueJS(let value):
            print(state.wkCoordinatorID)
            if let id = state.wkCoordinatorID{
                NotificationCenter.default.post(name: .WKCoordinatorQueueJS, object: value , userInfo: ["id":id] )
            }
        case .receiveMessage(_, let id):
            if state.wkCoordinatorID == nil{
                state.wkCoordinatorID = id
                print(state.wkCoordinatorID)
            }
            break
        }
        return .none
    }
}
