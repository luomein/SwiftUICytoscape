
import SwiftUI
import WebKit


public struct WKListenQueueJSView: View {
    //let coordinator: WKCoordinator
    @Environment(\.wkCoordinator) private var coordinator: WKCoordinator
    public var body: some View {
        EmptyView()
            .onReceive(NotificationCenter.default.publisher(for: .WKCoordinatorQueueJS)) { value in
                coordinator.queueJS(js: value.object as! String)
            }
    }
}

public struct WKListenWKCoordinatorNotificationView : View{
    
    public var body: some View {
        EmptyView()
            .onReceive(NotificationCenter.default.publisher(for: .WKCoordinatorNotification)) { value in
                
            }
    }
}
