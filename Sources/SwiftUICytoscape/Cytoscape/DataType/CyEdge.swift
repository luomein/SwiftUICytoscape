//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/11/5.
//

import Foundation

public struct CyEdge: Codable, Identifiable, Equatable, Hashable {
    //public let data : CyNodeData
    public var data : CyEdgeData
    public var classes : [String]?
    public var id : String{
        return data.id
    }
    public init(id: String, label: String, classes : [String]? = nil
                , source: String, target: String) {
        self.data = .init(id: id, source: source, target: target, label: label)
        self.classes = classes
    }
    public struct CyEdgeData: Codable, Equatable, Hashable{
        let id: String
        let source: String
        let target: String
        let label: String
    }
}
