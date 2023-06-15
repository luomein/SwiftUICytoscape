//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/6/15.
//

import Foundation
import IdentifiedCollections

public struct Node: Codable, Identifiable, Equatable {
    let data : NodeData
    public var id : String{
        return data.id
    }
    public init(data: NodeData) {
        self.data = data
    }
    public struct NodeData: Codable, Equatable{
        let id: String
        let label: String
        public init(id: String, label: String) {
            self.id = id
            self.label = label
        }
    }
    // Additional properties for nodes
    // ...
}

public struct Edge: Codable, Identifiable, Equatable  {
    let data : EdgeData
    public init(data: EdgeData) {
        self.data = data
    }
    public var id : String{
        return data.id
    }
    public struct EdgeData: Codable, Equatable{
        let id: String
        let source: String
        let target: String
        public init(id: String, source: String, target: String) {
            self.id = id
            self.source = source
            self.target = target
        }
    }
    // Additional properties for edges
    // ...
}

public struct GraphData: Codable, Equatable {
    var nodes: [Node]
    var edges: [Edge]
    public init(nodes: [Node], edges: [Edge]) {
        self.nodes = nodes
        self.edges = edges
    }
    var jsonString : String{
        let jsonData = try! JSONEncoder().encode(self)
        return String(data: jsonData, encoding: .utf8)!
    }
}
