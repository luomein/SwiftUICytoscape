//
//  SwiftUIView.swift
//  
//
//  Created by MEI YIN LO on 2023/10/11.
//

import SwiftUI
import ComposableArchitecture

public struct CyStyleReducerView: View {

    
    let store : StoreOf<CyStyleReducer>
    public init(store: StoreOf<CyStyleReducer>) {
        self.store = store
    }
    public var body: some View {
        WithViewStore(self.store, observe: {$0}) { viewStore in
            DisclosureGroup {
                List{
                    ColorPicker(selection: viewStore.binding(get: {
                        if let rgb = $0.style.backgroundColor?.hasPrefix("rgb"), rgb == true {
                            return CyStyle.extractJavascriptRGBValues(from: $0.style.backgroundColor!)
                        }
                        else{
                            return Color(.init(stringLiteral: $0.style.backgroundColor ?? "black"))
                            //return Color($0.style.backgroundColor ?? "black")
                        }
                    }, send: {color in
                        CyStyleReducer.Action.setBackgroundColor(color)
                    }
                                                             
                                                            ), label: {Text("background-color")})
                }
            } label: {
                Text("style")
            }

            
        }
    }
}
