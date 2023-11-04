//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/10/23.
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

///
///https://blog.js.cytoscape.org/2020/05/11/layouts/
///
public enum CyLayout: String, Codable, Equatable, Hashable, CaseIterable, Identifiable{
    case grid
    case fcose
    case circle
    case concentric
    case avsdf //Whereas the circle layout is useful when you want to order the nodes yourself, the avsdf layout is useful when you want to automatically order the nodes to try to avoid edge overlap.
    case dagre
    case breadthfirst
    
    public var id: String{
        return rawValue
    }
}
public struct CyGraph: Encodable, Equatable, Hashable {
    public var nodes: [CyNode]
    public var edges: [CyEdge]
    
    public var layout : CyLayout
    
//    enum CodingKeys: String, CodingKey {
//        case nodes
//        case edges
//    }
    public static var emptyGraph : Self = .init(nodes: [], edges: [])
    public init(nodes: [CyNode], edges: [CyEdge], layout: CyLayout = .fcose) {
        self.nodes = nodes
        self.edges = edges
        self.layout = layout
    }
    var jsonString : String{
        let jsonData = try! JSONEncoder().encode(self)
        return String(data: jsonData, encoding: .utf8)!
    }
}
