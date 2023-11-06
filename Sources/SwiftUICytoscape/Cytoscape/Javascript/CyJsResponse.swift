//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/10/9.
//

import Foundation

public enum CyJsResponse : String, CaseIterable{
    public enum CyJsResponseEventType : String, Decodable{
        case click
        case tap
        
        public var isClickOrTap : Bool{
            return self == .click || self == .tap
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let status = try! container.decode(String.self)
            self = Self(rawValue: status)!
            
        }
    }
    public struct CyJsResponseData: Decodable, Equatable, Hashable{
        public var eventType : CyJsResponseEventType
        public var targetId : String
        public var targetLabel : String
        public var isNode : Bool
        public var isEdge : Bool
    }
    case DOMContentLoaded
    case CytoscapeEvent

}
