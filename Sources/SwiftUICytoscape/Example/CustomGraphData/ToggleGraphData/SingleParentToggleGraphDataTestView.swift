//
//  SwiftUIView.swift
//  
//
//  Created by MEI YIN LO on 2023/10/25.
//

import SwiftUI
import ComposableArchitecture

extension SingleParentToggleGraphDataReducer{
    public static let store : StoreOf<SingleParentToggleGraphDataReducer> = .init(initialState: .init(), reducer: {SingleParentToggleGraphDataReducer()})
}
extension SingleParentToggleGraphDataReducer.State{
    public var cyGraph : CyGraph{
        let filteredNodes  = nodes
            .filter({currentNode in
                currentNode.nodeStatus.isVisible
            })
            
        return .init(nodes: filteredNodes.map({
            var node = $0.node
            node.classes = [$0.nodeStatus.rawValue]
            return node
        }), edges:
            filteredNodes.filter({
                return $0.parentNodeID != nil
            })
            .map({currentNode in
                return CyEdge.init(id: "e_" + currentNode.id, label: currentNode.id, source: currentNode.id, target: currentNode.parentNodeID!)
            })
                     ,layout: self.joinCyGraphDataReducerState.cyGraph.layout
        )
    }
}
extension SingleParentToggleGraphDataReducer.State{
    public func hasCircular(node: SingleParentToggleGraphDataReducer.ToggleGraphDataNode, nodeChain : inout IdentifiedArrayOf<SingleParentToggleGraphDataReducer.ToggleGraphDataNode>  )->Bool{
        if node.parentNodeID == nil{
            return false
        }
        if node.parentNodeID == node.id{
            return true
        }
        let parentNode = nodes[id: node.parentNodeID!]!
        
        if nodeChain[id:parentNode.id] != nil{
            print(nodeChain, parentNode.id)
            print("has circular")
            return true
        }
        nodeChain.append(parentNode)
        return hasCircular(node: parentNode, nodeChain: &nodeChain)
    }
    public func acceptNewNode(newNode: SingleParentToggleGraphDataReducer.ToggleGraphDataNode)->Bool{
        var nodeChain : IdentifiedArrayOf<SingleParentToggleGraphDataReducer.ToggleGraphDataNode> = []
        return !hasCircular(node: newNode, nodeChain: &nodeChain)
    }
    public static func bottomUpNodeStatus(node: SingleParentToggleGraphDataReducer.ToggleGraphDataNode, initialState: inout Self){
        assert( node.nodeStatus == .fullyExpanded )
        if node.parentNodeID == nil{return}
        initialState.nodes[id:node.parentNodeID!]!.nodeStatus = .fullyExpanded
        return bottomUpNodeStatus(node: initialState.nodes[id:node.parentNodeID!]!, initialState: &initialState)
    }
    public static func cascadeNodeStatus(parentNodeList : [SingleParentToggleGraphDataReducer.ToggleGraphDataNode], initialState: inout Self){
        let childrenNodes = initialState.nodes.filter {
            if let parentNodeID = $0.parentNodeID { return parentNodeList.map { $0.id }.contains( parentNodeID )}
            else{return false}
        }
        if childrenNodes.isEmpty{return}
        for id in childrenNodes.map({$0.id}){
            let childNodeStatus = initialState.nodes[id:id]!.nodeStatus
            let parentNodeStatus = initialState.nodes[id:initialState.nodes[id:id]!.parentNodeID!]!.nodeStatus
            initialState.nodes[id:id]!.nodeStatus = SingleParentToggleGraphDataReducer.ToggleGraphDataNode.NodeStatus.cascadeNodeStatus(parentNodeStatus:parentNodeStatus,childNodeStatus:childNodeStatus )
        }
        return cascadeNodeStatus(parentNodeList: childrenNodes.elements, initialState: &initialState)
    }
}
public struct SingleParentToggleGraphDataReducer : Reducer{
    @Dependency(\.context) var context
    public struct ToggleGraphDataNode: Identifiable, Equatable{
        public var node : CyNode
        public var isVisible : Bool{return nodeStatus.isVisible}
        public var parentNodeID : String?
        public var nodeStatus : NodeStatus = .fullyExpanded
        public var id: String{
            node.id
        }
        public enum NodeStatus: String, CaseIterable{
            case fullyExpanded
            case hidden
            case placeHolder
            case toggle
            public var cyStyle : CyStyle{
                let colorParserPrinter = JavascriptRGBColorParserPrinter()
                switch self{
                case .fullyExpanded:
                    return .init(selector: "." + self.rawValue, style: .init(backgroundColor: String(try! colorParserPrinter.print(.init(color: .black)) ) ))
                case .hidden:
                    return .init(selector: "." + self.rawValue, style: .init(backgroundColor: String(try! colorParserPrinter.print(.init(color: .black)) ) ))
                case .placeHolder:
                    return .init(selector: "." + self.rawValue, style: .init(backgroundColor: String(try! colorParserPrinter.print(.init(color: .gray)) ) , backgroundOpacity: "0.2" ))
                case .toggle:
                    return .init(selector: "." + self.rawValue, style: .init(backgroundColor: String(try! colorParserPrinter.print(.init(color: .red)) ) ))
                }
            }
            public var isVisible : Bool{return self != .hidden}
            static func cascadeNodeStatus(parentNodeStatus: Self, childNodeStatus: Self)->Self{
                if parentNodeStatus == .fullyExpanded{
                    if childNodeStatus.isVisible{
                        return childNodeStatus
                    }
                    else{
                        return .placeHolder
                    }
                    
                }
                else{
                    return .hidden
                }
            }

            static func toggleStatus(status: Self) -> Self{
                switch status{
                case .fullyExpanded:
                    return .toggle
                case .hidden:
                    fatalError()
                case .placeHolder:
                    return .fullyExpanded
                case .toggle:
                    return .fullyExpanded
                }
            }
        }
    }

    public struct State: Equatable{
        static var defaultStyle = CyStyle.defaultStyle + ToggleGraphDataNode.NodeStatus.allCases.map({$0.cyStyle})
        public var joinCyGraphDataReducerState : CyGraphDataReducer.State = .init(joinCyCommandReducerState: .init()
                                                                                  , joinCyStyleReducerState: IdentifiedArray(uniqueElements: State.defaultStyle)
                                                                                  , cyGraph: .emptyGraph)
        public var nodes : IdentifiedArrayOf<ToggleGraphDataNode> = []
     }
    public enum Action : Equatable{
        case toggleStatus(nodeID: String)
        case joinActionCyGraphDataReducer(CyGraphDataReducer.Action)
        case randomAdd
    }
    public var body: some Reducer<State, Action> {
        Scope(state: \.joinCyGraphDataReducerState, action: /Action.joinActionCyGraphDataReducer, child: {CyGraphDataReducer(initGraph: .emptyGraph
                                                                                                                             , initStyle: State.defaultStyle)})
        Reduce{state, action in
            switch action{
            case .randomAdd:
                let length = 10
                for _ in 1...length {
                    let newID = "\(Int.random(in: 0...1000))"
                    var parentNodeID : String? = nil
                    if !state.nodes.isEmpty{
                        parentNodeID = state.nodes[(Int.random(in: 0..<state.nodes.count)) ].id
                    }
                    var newNode = ToggleGraphDataNode(node: .init(id: newID, label: newID),  parentNodeID: parentNodeID)
                    newNode.nodeStatus = .fullyExpanded
                    if state.acceptNewNode(newNode: newNode){
                        state.nodes.append(newNode)
                        SingleParentToggleGraphDataReducer.State.bottomUpNodeStatus(node: newNode, initialState: &state)
                    }
                }
                return .send(.joinActionCyGraphDataReducer(.update(state.cyGraph) ))

            case .toggleStatus(let id):
                    state.nodes[id:id]!.nodeStatus = ToggleGraphDataNode.NodeStatus.toggleStatus(status: state.nodes[id:id]!.nodeStatus)
                    SingleParentToggleGraphDataReducer.State.cascadeNodeStatus(parentNodeList: [state.nodes[id:id]!], initialState: &state)
                    return .send(.joinActionCyGraphDataReducer(.update(state.cyGraph) ))
            case .joinActionCyGraphDataReducer(let subAction):
                switch subAction{
                case .joinActionCyCommandReducer(let command):
                    if case .cytoscapeEvent(let event) = command
                        , event.eventType.isClickOrTap
                        , event.isNode{
                        return .send(.toggleStatus(nodeID: event.targetId) )
                    }
                    break
                default:
                    break
                }

            }
            return .none
        }
        
    }
}
public struct SingleParentToggleGraphHeader: View {
    let store : StoreOf<SingleParentToggleGraphDataReducer>
    
    public init(store: StoreOf<SingleParentToggleGraphDataReducer>) {
        self.store = store
    }
    public var body: some View {
        WithViewStore(store, observe: {$0}) { viewStore in
            HStack{
                Text("Graph")
                Button {
                    viewStore.send(.randomAdd)
                } label: {
                    Text("add")
                }
                Button {
                    viewStore.send(.joinActionCyGraphDataReducer(.joinActionCyCommandReducer(.queueJS(.resetCanvas))))
                } label: {
                    Text("reset")
                }
            }
        }
    }
}
struct SingleParentToggleGraphDataTestView_Previews: PreviewProvider {
    static let store : StoreOf<SingleParentToggleGraphDataReducer> = SingleParentToggleGraphDataReducer.store
    
    static var previews: some View {
        Form{
            Section{
                CyWKWrapperView(store: store.scope(state:\.joinCyGraphDataReducerState.joinCyCommandReducerState.joinNotificationReducerState
                                                   , action: {
                    SingleParentToggleGraphDataReducer.Action.joinActionCyGraphDataReducer(
                        .joinActionCyCommandReducer(.joinActionNotificationReducer($0) ))
                }))
                .frame(height: 600)
            }header: {
                SingleParentToggleGraphHeader(store: store)
            }
        }
    }
}
