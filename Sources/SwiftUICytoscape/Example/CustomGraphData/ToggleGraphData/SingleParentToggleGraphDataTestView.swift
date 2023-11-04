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
        public var isExpanded : Bool {
            return nodeStatus.isExpanded
        }
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
                switch self{
                case .fullyExpanded:
                    return .init(selector: "." + self.rawValue, style: .init(backgroundColor: "rgb(25,100,0)"))
                case .hidden:
                    return .init(selector: "." + self.rawValue, style: .init(backgroundColor: "rgb(25,200,10)"))
                case .placeHolder:
                    return .init(selector: "." + self.rawValue, style: .init(backgroundColor: "rgb(125,200,110)"))
                case .toggle:
                    return .init(selector: "." + self.rawValue, style: .init(backgroundColor: "rgb(25,20,120)"))
                }
            }
            public var isExpanded : Bool {
                return self == .fullyExpanded
            }
            public var isVisible : Bool{return self != .hidden}
            static func cascadeNodeStatus(parentNodeStatus: Self, childNodeStatus: Self)->Self{
                if parentNodeStatus.isExpanded{
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
            static func toggleExpanded(status: Self) -> Self{
                switch status{
                case .fullyExpanded:
                    return .toggle
                case .hidden:
                    return    .fullyExpanded
                case .placeHolder:
                    return .fullyExpanded
                case .toggle:
                    return .fullyExpanded
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
    public struct ToggleGraphDataNodeReducer : Reducer{
        public typealias State = ToggleGraphDataNode
        public enum Action : Equatable{
            case toggleStatus
            case toggleExpanded
            case addChild(from: ToggleGraphDataNode)
        }
        public var body: some Reducer<State, Action> {
            Reduce{state, action in
                switch action{
                case .toggleExpanded:
                    state.nodeStatus = ToggleGraphDataNode.NodeStatus.toggleExpanded(status: state.nodeStatus)
                    
                case .toggleStatus:
                    state.nodeStatus = ToggleGraphDataNode.NodeStatus.toggleStatus(status: state.nodeStatus)
                case .addChild:
                    break
                }
                return .none
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
        case joinActionToggleGraphDataNodeReducer(ToggleGraphDataNodeReducer.State.ID, ToggleGraphDataNodeReducer.Action)
        case joinActionCyGraphDataReducer(CyGraphDataReducer.Action)
        case add(parent : ToggleGraphDataNode?)
    }
    public var body: some Reducer<State, Action> {
        Scope(state: \.joinCyGraphDataReducerState, action: /Action.joinActionCyGraphDataReducer, child: {CyGraphDataReducer(initGraph: .emptyGraph
                                                                                                                             , initStyle: State.defaultStyle)})
        
        Reduce{state, action in
            switch action{
            case .add(let parent):
                let newID = "\(Int.random(in: 0...1000))"
                var newNode = ToggleGraphDataNode(node: .init(id: newID, label: newID),  parentNodeID: parent?.id ?? nil)
                print(newNode)
                newNode.nodeStatus = .fullyExpanded
                
                if state.acceptNewNode(newNode: newNode){
                    state.nodes.append(newNode)
                    SingleParentToggleGraphDataReducer.State.bottomUpNodeStatus(node: newNode, initialState: &state)
                    return .send(.joinActionCyGraphDataReducer(.update(state.cyGraph) ))
                }
                else{
                    break
                }
            case .joinActionToggleGraphDataNodeReducer(let id, let subAction):
                switch subAction{
                case .toggleStatus:
                    let node = state.nodes[id:id]!
                    SingleParentToggleGraphDataReducer.State.cascadeNodeStatus(parentNodeList: [node], initialState: &state)
                    return .send(.joinActionCyGraphDataReducer(.update(state.cyGraph) ))
                case .toggleExpanded:
                    let node = state.nodes[id:id]!
                    if node.nodeStatus.isExpanded{
                        SingleParentToggleGraphDataReducer.State.bottomUpNodeStatus(node: node, initialState: &state)
                        SingleParentToggleGraphDataReducer.State.cascadeNodeStatus(parentNodeList: [node], initialState: &state)
                    }else{
                        SingleParentToggleGraphDataReducer.State.cascadeNodeStatus(parentNodeList: [node], initialState: &state)
                    }
                    return .send(.joinActionCyGraphDataReducer(.update(state.cyGraph) ))
                case .addChild(let node):
                    return .send(.add(parent: node))
                }
            case .joinActionCyGraphDataReducer(let subAction):
                switch subAction{
                case .joinActionCyCommandReducer(let command):
                    
                    if case .cytoscapeEvent(let event) = command
                        , event.eventType.isClickOrTap
                        , event.isNode{
                        return .send(.joinActionToggleGraphDataNodeReducer(event.targetId, .toggleStatus) )
                    }
                    break
                default:
                    break
                }

            }
            return .none
        }
        .forEach(\.nodes, action: /Action.joinActionToggleGraphDataNodeReducer, element: {ToggleGraphDataNodeReducer()})
    }
}
struct SingleParentToggleGraphDataNodeTestView: View {
    let store : StoreOf<SingleParentToggleGraphDataReducer.ToggleGraphDataNodeReducer>
    var body: some View {
        WithViewStore(self.store, observe: {$0}) { viewStore in
            DisclosureGroup( viewStore.id
                             , isExpanded: viewStore.binding(get:  \.isExpanded, send: .toggleExpanded )) {
                Button {
                    viewStore.send(.addChild(from: viewStore.state))
                } label: {
                    Text("add child")
                }
            }
            
        }
    }
}
public struct SingleParentToggleGraphDataTestView: View {
    let store : StoreOf<SingleParentToggleGraphDataReducer> = SingleParentToggleGraphDataReducer.store
    let showColorIndicateViewRefresh : Bool
    public init(showColorIndicateViewRefresh: Bool = false){
        self.showColorIndicateViewRefresh = showColorIndicateViewRefresh
    }
    public var body: some View {
        
        Section
            {
                    WithViewStore(self.store, observe: {$0}) { viewStore in
                        if showColorIndicateViewRefresh{
                            Text("showColorIndicateViewRefresh")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(getRandomColor())
                        }
                        else{
                            EmptyView()
                        }
                        Button {
                            viewStore.send(.add(parent: nil))
                        } label: {
                            Text("add")
                        }
                        
                        ForEachStore(
                            self.store.scope(state: \.nodes, action: { .joinActionToggleGraphDataNodeReducer($0, $1) })
                        ) { subStore in
                            SingleParentToggleGraphDataNodeTestView(store: subStore)
                        }
                    }
                    
                }
          

        
    }
}
func getRandomColor() -> Color{
    let alpha : Double = 0.3
    return .init(red: Double(Int.random(in: 0...255))/255
                 , green: Double(Int.random(in: 0...255))/255
                 , blue: Double(Int.random(in: 0...255))/255
                 , opacity: alpha
    )
}
struct SingleParentToggleGraphDataTestView_Previews: PreviewProvider {
    static let store : StoreOf<SingleParentToggleGraphDataReducer> = SingleParentToggleGraphDataReducer.store
    
    static var previews: some View {
        Form{
            SingleParentToggleGraphDataTestView(showColorIndicateViewRefresh: true)
                
            CyWKCoordinatorSwiftUIView()
                .frame(height: 300)
            
            Section("listener") {
                WKNotificationReducerSwiftUIView(store: store.scope(state: \.joinCyGraphDataReducerState.joinCyCommandReducerState.joinNotificationReducerState, action: {
                    SingleParentToggleGraphDataReducer.Action.joinActionCyGraphDataReducer(.joinActionCyCommandReducer(.joinActionNotificationReducer($0) )
                    )
                 })
                , showColorIndicateViewRefresh: true
                )
                
            }
        }
    }
}
