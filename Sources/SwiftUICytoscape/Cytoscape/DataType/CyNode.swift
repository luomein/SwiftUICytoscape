//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/11/5.
//

import Foundation


public struct CyNode: Codable, Identifiable, Equatable, Hashable {
    public var data : CyNodeData
    public var classes : [String]?
    public var id : String{
        return data.id
    }
    public init(id: String, label: String, classes : [String]? = nil) {
        self.data = .init(id: id, label: label)
        self.classes = classes
    }
    public struct CyNodeData: Codable, Equatable, Hashable{
        let id: String
        var label: String
        public init(id: String, label: String) {
            self.id = id
            self.label = label
        }
    }
}
