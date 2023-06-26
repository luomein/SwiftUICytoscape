//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/6/15.
//

import Foundation
import IdentifiedCollections


public struct SetDBNode: Codable, Identifiable, Equatable, Hashable {
    public let data : CyNodeData
    public var classes : [String]?
    public var id : String{
        return data.id
    }
    public init(data: CyNodeData, classes : [String]? = nil) {
        self.data = data
        self.classes = classes
    }
    public struct CyNodeData: Codable, Equatable, Hashable{
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

public struct SetDBEdge: Codable, Identifiable, Equatable , Hashable {
    let data : CyEdgeData
    public var classes : [String]?
    public init(data: CyEdgeData) {
        self.data = data
    }
    public var id : String{
        return data.id
    }
    public struct CyEdgeData: Codable, Equatable, Hashable{
        let id: String
        let source: String
        let target: String
        let label: String
        public init(id: String, source: String, target: String, label: String = "\(Int.random(in: 0...100))") {
            self.id = id
            self.source = source
            self.target = target
            self.label = label
        }
    }
    // Additional properties for edges
    // ...
}

public struct SetDBGraphData: Codable, Equatable, Hashable {
    public var nodes: [SetDBNode]
    public var edges: [SetDBEdge]
    public static var emptyGraph : Self = .init(nodes: [], edges: [])
    public init(nodes: [SetDBNode], edges: [SetDBEdge]) {
        self.nodes = nodes
        self.edges = edges
    }
    var jsonString : String{
        let jsonData = try! JSONEncoder().encode(self)
        return String(data: jsonData, encoding: .utf8)!
    }
    public func hasNode(nodeID : SetDBNode.ID)->Bool{
        return self.nodes.map({$0.id}).contains(nodeID)
    }
    public func hasConnection(nodeID_0 : SetDBNode.ID, nodeID_1 : SetDBNode.ID)->Bool{
        return getConnection(nodeID_0: nodeID_0, nodeID_1: nodeID_1) != nil
    }
    public func getConnection(nodeID_0 : SetDBNode.ID, nodeID_1 : SetDBNode.ID)->SetDBEdge?{
        return edges.first(where: {($0.data.source == nodeID_0 && $0.data.target == nodeID_1) || ($0.data.source == nodeID_1 && $0.data.target == nodeID_0) })
    }
    public func updateClass(referenceGraphData: Self, className: String)->Self{
        var graphData = self
        graphData.nodes = graphData.nodes.map({
            if referenceGraphData.nodes.map({$0.id}).contains($0.id){
                var node = $0
                node.classes = (node.classes ?? []) + [className]
                return node
            }
            else{
                return $0
            }
        })
        graphData.edges = graphData.edges.map({
            if referenceGraphData.edges.map({$0.id}).contains($0.id){
                var edge = $0
                edge.classes = (edge.classes ?? []) + [className]
                return edge
            }
            else{
                return $0
            }
        })
        return graphData
    }
    public static func getUnionGraphData(graphDataList : [SetDBGraphData])->Self{
        let nodes : [SetDBNode] = graphDataList.reduce(into: Set<SetDBNode>()) {
            $0 = $0.union(Set($1.nodes))
        }.map({$0})
        let edges : [SetDBEdge] = graphDataList.reduce(into: Set<SetDBEdge>()) {
            $0 = $0.union(Set($1.edges))
        }.map({$0})
        return .init(nodes: nodes, edges: edges)
    }
    public static func getIntersectGraphData(graphDataList : [SetDBGraphData])->Self{
        var graphDataList = graphDataList
        if graphDataList.count == 0{return .emptyGraph}
        let firstGraphData = graphDataList.removeFirst()
        let nodes : [SetDBNode] = graphDataList.reduce(into: Set(firstGraphData.nodes)) {
            $0 = $0.intersection(Set($1.nodes))
        }.map({$0})
        let edges : [SetDBEdge] = graphDataList.reduce(into: Set(firstGraphData.edges)) {
            $0 = $0.intersection(Set($1.edges))
        }.map({$0})
        return .init(nodes: nodes, edges: edges)
    }
    public func getConnectedGraphData(from nodes:[SetDBNode],positiveNodes:[SetDBNode], start graphData: Self)->Self{
        var appendedGraphData : SetDBGraphData = graphData
        let positiveNodesClasses : [String] = Set(positiveNodes.flatMap({$0.classes ?? []})).map({$0})
        let negativeNodes : [SetDBNode] = self.nodes.filter({
            let classes = $0.classes ?? []
            let hasPositiveNodesClasses = Set(positiveNodesClasses).intersection(classes).count > 0
            return !positiveNodes.contains($0) && hasPositiveNodesClasses
        })
//        let neutralNodes : [CyNode] = self.nodes.filter({
//            let classes = $0.classes ?? []
//            let hasPositiveNodesClasses = Set(positiveNodesClasses).intersection(classes).count > 0
//            return !hasPositiveNodesClasses
//        })
        for node in nodes {
            let connectedNodes = self.nodes.filter({
                    self.hasConnection(nodeID_0: $0.id, nodeID_1: node.id) && !graphData.hasConnection(nodeID_0: $0.id, nodeID_1: node.id)
                })
            if connectedNodes.count == 0{continue}
            appendedGraphData.nodes.append(contentsOf:connectedNodes)
            appendedGraphData.edges.append(contentsOf: connectedNodes.map({self.getConnection(nodeID_0: $0.id, nodeID_1: node.id)!}))
            let filteredConnectedNodes = connectedNodes.filter({
                !negativeNodes.contains($0)
            })
            appendedGraphData = getConnectedGraphData(from: filteredConnectedNodes
                                                      , positiveNodes: positiveNodes, start: appendedGraphData)
        }
        return appendedGraphData
    }
}
