//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/10/11.
//

import Foundation
import ComposableArchitecture
import SwiftUI

public struct CyStyleReducer : Reducer{
    
    public init() {}
    public typealias State = CyStyle
    
    public enum Action : Equatable{
        case setSelector(String)
        case setColor(attribute: WritableKeyPath<CyStyle.CyStyleData,String?>, Color)
        case setAttribute(attribute: WritableKeyPath<CyStyle.CyStyleData,String?>, value: String?)
        case setShape(CyStyle.CyStyleData.CyShape)
        
    }
    public var body: some Reducer<State, Action> {
        Reduce{state, action in
            switch action{
            
            case .setSelector(let value):
                state.selector = value
            case .setShape(let shape):
                if shape == .none{state.style.shape = nil}
                else{state.style.shape = shape}
//            case .setContent(let value):
//                if value == .none{state.style.content = nil}
//                else{state.style.content = value.rawValue}
            case .setColor(let attribute, let color):
                state.style[keyPath: attribute] = CyStyle.convertRGBToJavascriptString(color: color)
            case .setAttribute(let attribute,let value):
                state.style[keyPath: attribute] = value
            }
            return .none
        }
    }
}
