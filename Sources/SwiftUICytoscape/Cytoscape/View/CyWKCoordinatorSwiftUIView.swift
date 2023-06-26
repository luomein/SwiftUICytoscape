//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/10/9.
//

import Foundation
import SwiftUI
import ComposableArchitecture
import WebKit

public struct  CyWKCoordinatorSwiftUIView : View{
    public init(){}
    public var body: some View {
            JavascriptWKCoordinatorSwiftUIView(coordinatorID: CyCommandReducer.wkCoordinatorID.defaultValue.rawValue
                                               , eventNames: CyJsResponse.allCases.map({$0.rawValue})
                                               , htmlFileUrl: Bundle.module.url(forResource: "index", withExtension: "html")!
                                               , jsFiles: [
                                                Bundle.module.url(forResource: "cytoscape.min.mein", withExtension: "js")!,
                                                Bundle.module.url(forResource: "cytoscape.event", withExtension: "js")!
                                               ]
                                               , fromWKCoordinatorNotification: .fromCyWKCoordinatorNotification
                                               , toWKCoordinatorNotification: .toCyWKCoordinatorNotification)
            
        
    }
}

