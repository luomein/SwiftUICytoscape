//
//  SwiftUIView.swift
//  
//
//  Created by MEI YIN LO on 2023/10/21.
//

import SwiftUI
import ComposableArchitecture
import WebKit

struct ExampleSwiftUIView: View {
    static let FromWKCoordinatorNotification = Notification.Name("FromWKCoordinatorNotification")
    static let ToWKCoordinatorNotification = Notification.Name("ToWKCoordinatorNotification")
    enum WKMessageHandlersEvent: String, CaseIterable{
        case test
        case DOMContentLoaded
    }
    enum coordinatorID : String{
        case coordinatorID_001
    }
    let store : StoreOf<NotificationReducer<WKScriptMessage>>
    struct SubView: View {
        let store : StoreOf<NotificationReducer<WKScriptMessage>>
        var body: some View {
            WithViewStore(self.store, observe: {$0}) { viewStore in
                VStack{
                    Text("receive message from javascript: ")
                    if let receiveMessage = viewStore.receiveMessage as? WKScriptMessage{
                        Text(receiveMessage.body as! String)
                    }
                    Button {
                        let message = "getTime();"
                        viewStore.send(.postNotification(message))
                    } label: {
                        Text("call javascript from SwiftUI View")
                    }
                }
                .task {
                    await viewStore.send(.listening).finish()
                }
            }
        }
    }
    private func createTemporaryHTMLFile(content: String, tempFileName: String) -> URL? {
            do {
                // Create a temporary directory
                let temporaryDirectory = FileManager.default.temporaryDirectory
                let temporaryFileURL = temporaryDirectory.appendingPathComponent(tempFileName)

                // Write the HTML content to the temporary file
                try content.write(to: temporaryFileURL, atomically: true, encoding: .utf8)

                return temporaryFileURL
            } catch {
                print("Error creating a temporary HTML file: \(error)")
                return nil
            }
        }
    var htmlContent = """
<div id="click_me" style="font-size: 80;" onclick="getTime();">call javascript from html</div>
"""
    var js1Content = """
document.addEventListener('DOMContentLoaded', function () {
    webkit.messageHandlers.DOMContentLoaded.postMessage('DOMContentLoaded');
});
"""
    var js2Content = """
function getTime(){
    window.webkit.messageHandlers.test.postMessage(Date());
}
"""
    
    var body: some View {
            VStack{
                SubView(store: store)
                JavascriptWKCoordinatorSwiftUIView(coordinatorID: coordinatorID.coordinatorID_001.rawValue
                                                   , eventNames: WKMessageHandlersEvent.allCases.map({$0.rawValue})
                                                   , htmlFileUrl: createTemporaryHTMLFile(content: htmlContent, tempFileName: "index.html")!
                                                   , jsFiles: [
                                                    createTemporaryHTMLFile(content: js1Content, tempFileName: "event1.js")!,
                                                    createTemporaryHTMLFile(content: js2Content, tempFileName: "event2.js")!
                                                   ]
                                                   , fromWKCoordinatorNotification: ExampleSwiftUIView.FromWKCoordinatorNotification
                                                   , toWKCoordinatorNotification: ExampleSwiftUIView.ToWKCoordinatorNotification)
                
            }.padding()
    }
}

struct ExampleSwiftView_Previews: PreviewProvider {
    static let store = Store(initialState: NotificationReducer<WKScriptMessage>.State()) {
        NotificationReducer<WKScriptMessage>(listenNotificationName: ExampleSwiftUIView.FromWKCoordinatorNotification
                                             , postNotificationName: ExampleSwiftUIView.ToWKCoordinatorNotification
                                    , coordinatorID: ExampleSwiftUIView.coordinatorID.coordinatorID_001.rawValue)
        }
    
    static var previews: some View {
        ExampleSwiftUIView(store: store)
    }
}
