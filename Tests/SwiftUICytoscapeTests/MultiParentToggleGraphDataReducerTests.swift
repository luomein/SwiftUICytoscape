//
//  MultiParentToggleGraphDataReducerTests.swift
//  labSwiftUICytoscapeExampleTests
//
//  Created by MEI YIN LO on 2023/10/30.
//

import XCTest
@testable import SwiftUICytoscape
import ComposableArchitecture

@MainActor
final class MultiParentToggleGraphDataReducerTests: XCTestCase {

    func test() async throws{
        let nodeA = MultiParentToggleGraphDataReducer.ToggleGraphDataNode.init(node: .init(id: "A", label: "A"))
        let nodeB = MultiParentToggleGraphDataReducer.ToggleGraphDataNode.init(node: .init(id: "B", label: "B"))
        let nodeC = MultiParentToggleGraphDataReducer.ToggleGraphDataNode.init(node: .init(id: "C", label: "C") )
        let nodeD = MultiParentToggleGraphDataReducer.ToggleGraphDataNode.init(node: .init(id: "D", label: "D") )
        let store = TestStore(initialState: MultiParentToggleGraphDataReducer.State(nodes: .init(uniqueElements: [nodeA, nodeB, nodeC, nodeD])
                                                                                    ,relations: .init(uniqueElements: [
                                                                                        .init(parentNodeID: "A", childNodeID: "C", isVisible: true)
                                                                                    ])), reducer: {MultiParentToggleGraphDataReducer()})
       
        
        
        await store.send(.addParent(child: nodeA, parent: nodeB)){
            $0.relations.append(.init(parentNodeID: "B", childNodeID: "A", isVisible: true))
        }
        await store.receive(.updateCyGraph, timeout: .zero)
        
        await store.send(.addParent(child: nodeB, parent: nodeD)){
            $0.relations.append(.init(parentNodeID: "D", childNodeID: "B", isVisible: true))
        }
        await store.receive(.updateCyGraph, timeout: .zero)
        
        //test duplicate
        await store.send(.addParent(child: nodeB, parent: nodeD))
        await store.receive(.updateCyGraph, timeout: .zero)
        
        //test circular
        await store.send(.addParent(child: nodeD, parent: nodeA))
        
        //test close loop, but not circular
        await store.send(.addParent(child: nodeC, parent: nodeB)){
            $0.relations.append(.init(parentNodeID: "B", childNodeID: "C", isVisible: true))
        }
        await store.receive(.updateCyGraph, timeout: .zero)
        
        
    }

}
