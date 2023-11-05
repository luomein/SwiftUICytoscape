//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/10/23.
//

import Foundation




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
