
import SwiftUI
import WebKit
import ComposableArchitecture

//public struct WKListenQueueJSView: View {
//    //let coordinator: WKCoordinator
//    @Environment(\.wkCoordinator) private var coordinator: WKCoordinator
//    public init(){}
//    public var body: some View {
//        EmptyView()
//            .onReceive(NotificationCenter.default.publisher(for: .WKCoordinatorQueueJS)) { value in
//                print(value.userInfo?["id"], coordinator.id)
//                if let id = value.userInfo?["id"] as? UUID, id == coordinator.id{
//                    coordinator.queueJS(js: value.object as! String)
//                }
//            }
//    }
//}

public struct WKListenWKCoordinatorNotificationView : View{
    @Environment(\.wkCoordinator) private var coordinator: WKCoordinator
    let store : StoreOf<WKReducer>
    public init(store: StoreOf<WKReducer>) {
        self.store = store
    }
    public var body: some View {
        WithViewStore(self.store, observe: {$0}) { viewStore in
            EmptyView()
                .onReceive(NotificationCenter.default.publisher(for: .WKCoordinatorQueueJS)) { value in
                    print(value.userInfo?["id"], coordinator.id)
                    if let id = value.userInfo?["id"] as? UUID, id == coordinator.id{
                        if viewStore.wkCoordinatorID  == nil{
                            viewStore.send(.setCoordinatorID(id))
                        }
                        coordinator.queueJS(js: value.object as! String)
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: .WKCoordinatorNotification)) { value in
                    print(value.userInfo?["id"], viewStore.wkCoordinatorID)
                    if let id = value.userInfo?["id"] as? UUID, id == coordinator.id{
                        viewStore.send(.receiveMessage(value.object as! WKScriptMessage, id))
                    }
                }
        }
    }
}
