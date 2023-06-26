//
//  SwiftUIView.swift
//  
//
//  Created by MEI YIN LO on 2023/10/25.
//

import SwiftUI
import ComposableArchitecture

public struct CyStyleReducerTestView: View {
    let store : StoreOf<CyStyleReducer> = .init(initialState: .nodeStyle, reducer: {CyStyleReducer()})
    public init(){}
    public var body: some View {
        Form{
            CyStyleReducerView(store: store)
        }
    }
}
struct CyStyleReducerTestView_Previews: PreviewProvider {
    static var previews: some View {
        CyStyleReducerTestView()
        //Text("test")
    }
}
