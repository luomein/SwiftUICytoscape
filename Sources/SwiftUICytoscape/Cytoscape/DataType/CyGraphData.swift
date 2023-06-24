//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/6/15.
//

import Foundation
import IdentifiedCollections

public struct CyNode: Codable, Identifiable, Equatable {
    let data : CyNodeData
    let classes : [String]?
    public var id : String{
        return data.id
    }
    public init(data: CyNodeData, classes : [String]? = nil) {
        self.data = data
        self.classes = classes
    }
    public struct CyNodeData: Codable, Equatable{
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

public struct CyEdge: Codable, Identifiable, Equatable  {
    let data : CyEdgeData
    public init(data: CyEdgeData) {
        self.data = data
    }
    public var id : String{
        return data.id
    }
    public struct CyEdgeData: Codable, Equatable{
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

public struct CyGraphData: Codable, Equatable {
    public var nodes: [CyNode]
    public var edges: [CyEdge]
    public static var emptyGraph : Self = .init(nodes: [], edges: [])
    public init(nodes: [CyNode], edges: [CyEdge]) {
        self.nodes = nodes
        self.edges = edges
    }
    var jsonString : String{
        let jsonData = try! JSONEncoder().encode(self)
        return String(data: jsonData, encoding: .utf8)!
    }
    public func hasConnection(nodeID_0 : CyNode.ID, nodeID_1 : CyNode.ID)->Bool{
        return edges.first(where: {($0.data.source == nodeID_0 && $0.data.target == nodeID_1) || ($0.data.source == nodeID_1 && $0.data.target == nodeID_0) }) != nil
    }
}
