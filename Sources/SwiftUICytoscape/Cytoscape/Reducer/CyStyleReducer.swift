//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/10/11.
//

import Foundation
import ComposableArchitecture
import SwiftUI

public struct CyStyleReducer : ReducerProtocol{
    
    public init() {}
    public typealias State = CyStyle
    
    public enum Action : Equatable{
        case setBackgroundColor(Color)
        case setAttribute(attribute: WritableKeyPath<CyStyle.CyStyleData,String?>, value: String)
    }
    public var body: some ReducerProtocol<State, Action> {
        Reduce{state, action in
            switch action{
            case .setBackgroundColor(let color):
                state.style.backgroundColor = CyStyle.convertRGBToJavascriptString(color: color)
            case .setAttribute(let attribute,let value):
                state.style[keyPath: attribute] = value
            }
            return .none
        }
    }
}
