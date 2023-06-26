//
//  NotificationReducerTests.swift
//  
//
//  Created by MEI YIN LO on 2023/10/21.
//

import XCTest
@testable import SwiftUICytoscape
import ComposableArchitecture
import WebKit



@MainActor
final class NotificationReducerTests: XCTestCase {
    enum coordinatorID : String{
        case coordinatorID_001
    }
    let FromWKCoordinatorNotification = Notification.Name("FromWKCoordinatorNotification")
    let ToWKCoordinatorNotification = Notification.Name("ToWKCoordinatorNotification")
    func test() async{
        let store = TestStore(initialState: NotificationReducer<String>.State()) {
            NotificationReducer<String>(listenNotificationName: FromWKCoordinatorNotification
                                        , postNotificationName: ToWKCoordinatorNotification
                                , coordinatorID: coordinatorID.coordinatorID_001.rawValue)
            }
        let task = await store.send(.listening)
        let message = "test"
        NotificationCenter.default.post(name: FromWKCoordinatorNotification
                                        , object: message
                                        ,userInfo: ["id": coordinatorID.coordinatorID_001.rawValue] )
        await store.receive(.receive(message), timeout: .zero){
            $0.receiveMessage = message
        }

        await task.cancel()
        
        NotificationCenter.default.post(name: FromWKCoordinatorNotification
                                        , object: message
                                        ,userInfo: ["id": coordinatorID.coordinatorID_001.rawValue] )
    }

}
