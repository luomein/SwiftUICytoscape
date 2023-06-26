//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/10/21.
//


import Foundation
import ComposableArchitecture
import WebKit

public struct NotificationReducer<T:Equatable> : Reducer{
    var notificationAsyncStream: @Sendable ()  -> AsyncStream<Notification>
    var listenNotificationName : Notification.Name
    var postNotificationName : Notification.Name
    var userInfoID : String
    public init(listenNotificationName: Notification.Name, postNotificationName: Notification.Name, coordinatorID: String) {
        self.listenNotificationName = listenNotificationName
        self.postNotificationName = postNotificationName
        self.userInfoID = coordinatorID
        self.notificationAsyncStream = {
            AsyncStream(
                NotificationCenter.default
                    .notifications(named: listenNotificationName)
            )
        }
    }
    public struct State: Equatable{
        var receiveMessage : T?
        public init() {}
    }
    public enum Action : Equatable{
        case postNotification(String)
        case listening
        case receive(T)
    }
    public func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action{
        case .postNotification(let value):
            NotificationCenter.default.post(name: postNotificationName
                                            , object: value, userInfo: ["id": userInfoID])
        case .listening:
          return .run { send in
            for await notification in self.notificationAsyncStream() {
                if let id = notification.userInfo?["id"] as? String, id == userInfoID{
                    await send(.receive(notification.object as! T))
                }
            }
          }

        case .receive(let message):
            state.receiveMessage = message
        }
        return .none
    }
}


