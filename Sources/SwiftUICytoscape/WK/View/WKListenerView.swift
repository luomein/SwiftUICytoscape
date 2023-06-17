
import SwiftUI
import WebKit
import ComposableArchitecture

public struct WKListenQueueJSView: View {
    //let coordinator: WKCoordinator
    @Environment(\.wkCoordinator) private var coordinator: WKCoordinator
    public init(){}
    public var body: some View {
        EmptyView()
            .onReceive(NotificationCenter.default.publisher(for: .WKCoordinatorQueueJS)) { value in
                coordinator.queueJS(js: value.object as! String)
            }
    }
}

public struct WKListenWKCoordinatorNotificationView : View{
    let store : StoreOf<WKReducer>
    public init(store: StoreOf<WKReducer>) {
        self.store = store
    }
    public var body: some View {
        WithViewStore(self.store, observe: {$0}) { viewStore in
            EmptyView()
                .onReceive(NotificationCenter.default.publisher(for: .WKCoordinatorNotification)) { value in
                    viewStore.send(.receiveMessage(value.object as! WKScriptMessage))
                }
        }
    }
}
