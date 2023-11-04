//
//  SwiftUIView.swift
//  
//
//  Created by MEI YIN LO on 2023/10/29.
//

import SwiftUI
import ComposableArchitecture

extension MultiParentToggleGraphDataReducer{
    public static let store : StoreOf<MultiParentToggleGraphDataReducer> = .init(initialState: .init(), reducer: {MultiParentToggleGraphDataReducer()})
}
extension MultiParentToggleGraphDataReducer.State{
    //    public static func cascadeNodeStatus(parentNodeList : [MultiParentToggleGraphDataReducer.ToggleGraphDataNode], initialState: inout Self){
    //        let childrenNodes = initialState.nodes.filter {
    //            let intersection = Set(parentNodeList.map({$0.id})).intersection($0.parentNodeIDs)
    //            return !intersection.isEmpty
    ////            if let parentNodeID = $0.parentNodeID { return parentNodeList.map { $0.id }.contains( parentNodeID )}
    ////            else{return false}
    //        }
    //        if childrenNodes.isEmpty{return}
    //        childrenNodes.forEach{childNode in
    //            let childNodeStatus = initialState.nodes[id:childNode.id]!.nodeStatus
    //            let childNodeParentList = initialState.nodes.filter {
    //                childNode.parentNodeIDs.contains($0.id)
    //            }
    //            let parentNodeStatus = Set(childNodeParentList.map({$0.nodeStatus}))
    //            initialState.nodes[id:childNode.id]!.nodeStatus = MultiParentToggleGraphDataReducer.ToggleGraphDataNode.NodeStatus.cascadeNodeStatus(parentNodeStatus:parentNodeStatus,childNodeStatus:childNodeStatus )
    //        }
    //        return cascadeNodeStatus(parentNodeList: childrenNodes.elements, initialState: &initialState)
    //    }
    public static func downTraceRelationInVisible(node: MultiParentToggleGraphDataReducer.ToggleGraphDataNode, initialState: inout Self){
        let downStream = initialState.getDownStreamRelation(of: node)
        if downStream.isEmpty{return}
        downStream.forEach { relation in
            let node = initialState.nodes[id: relation.childNodeID]!
            initialState.relations[id:relation.id]!.isVisible = false
            return downTraceRelationInVisible(node: node, initialState: &initialState)
        }
    }
    public static func upTraceRelationVisible(node: MultiParentToggleGraphDataReducer.ToggleGraphDataNode, initialState: inout Self){
        let upStream = initialState.getUpStreamRelation(of: node)
        if upStream.isEmpty{return}
        upStream.forEach { relation in
            let parentNode = initialState.nodes[id: relation.parentNodeID]!
            initialState.relations[id:relation.id]!.isVisible = true
            return upTraceRelationVisible(node: parentNode, initialState: &initialState)
        }
    }
    public func getUpStreamRelation(of node: MultiParentToggleGraphDataReducer.ToggleGraphDataNode)->Set<MultiParentToggleGraphDataReducer.ToggleGraphDataNodeParentRelation>{
        return Set(self.relations.filter {
            $0.childNodeID == node.id
        })
    }
    public func getChildNodes(of node: MultiParentToggleGraphDataReducer.ToggleGraphDataNode)->[MultiParentToggleGraphDataReducer.ToggleGraphDataNode]{
        let downStream = getDownStreamRelation(of: node)
        return downStream.map {
            nodes[id:$0.childNodeID]!
        }
    }
    public func getDownStreamRelation(of node: MultiParentToggleGraphDataReducer.ToggleGraphDataNode)->Set<MultiParentToggleGraphDataReducer.ToggleGraphDataNodeParentRelation>{
        return Set(self.relations.filter {
            $0.parentNodeID == node.id
        })
    }
    public func getNodeStatus(of node: MultiParentToggleGraphDataReducer.ToggleGraphDataNode)->MultiParentToggleGraphDataReducer.ToggleGraphDataNode.NodeStatus{
        let upStream = getUpStreamRelation(of: node)
        let downStream = getDownStreamRelation(of: node)
        return MultiParentToggleGraphDataReducer.ToggleGraphDataNode.NodeStatus.getNodeStatus(upStreamRelation: upStream, downStreamRelation: downStream)
    }
    public var cyGraph : CyGraph{
        guard checkIntegraty() else{fatalError()}
        let filteredNodes  = nodes
            .compactMap({currentNode in
                let nodeStatus = getNodeStatus(of: currentNode)
                if nodeStatus.isVisible{
                    var node = currentNode.node
                    node.classes = [nodeStatus.rawValue]
                    return node
                }
                return nil
            })
        let filteredEdges = relations.compactMap {
            if $0.isVisible{
                return CyEdge.init(id:  $0.id
                                   , label: $0.id, source: $0.childNodeID
                                   , target: $0.parentNodeID)
            }
            else{
                return nil
            }
        }
        return .init(nodes: filteredNodes
                     , edges: filteredEdges
                     , layout: self.joinCyGraphDataReducerState.cyGraph.layout
        )
    }
}


extension MultiParentToggleGraphDataReducer.State{
    public func hasCircular(startNode: MultiParentToggleGraphDataReducer.ToggleGraphDataNode
                            ,checkNode: MultiParentToggleGraphDataReducer.ToggleGraphDataNode
                            , nodeChain : inout IdentifiedArrayOf<MultiParentToggleGraphDataReducer.ToggleGraphDataNode>  )->Bool{
        //print(startNode.id, checkNode.id, nodeChain)
        let parentNodeIdList = relations.filter({
            $0.childNodeID == checkNode.id
        }).map({$0.parentNodeID})
        if parentNodeIdList.isEmpty{
            return false
        }

        if !relations.filter({
            $0.childNodeID == checkNode.id && $0.parentNodeID == checkNode.id
        }).isEmpty{
            return true
        }

        let parentNodeList = nodes.filter {
            parentNodeIdList.contains($0.id)
        }
        nodeChain.append(contentsOf: parentNodeList)
        if nodeChain.contains(startNode){
            return true
        }

        
        return parentNodeList.first { parentNode in
            hasCircular(startNode: startNode, checkNode: parentNode, nodeChain: &nodeChain)
        } != nil
        
    }
    public enum IntegratyCriteria: CaseIterable{
        case checkMissingNode
        case checkCircular
        case checkIDUnique
        
        public func passCriteria(state: MultiParentToggleGraphDataReducer.State)->Bool{
            let nodes = state.nodes
            let relations = state.relations
            let nodeIDs = nodes.map {
                $0.id
            }
            switch self{
            case .checkMissingNode:
                return relations.first {
                    !nodeIDs.contains($0.childNodeID) || !nodeIDs.contains($0.parentNodeID)
                } == nil
            case .checkCircular:
                return nodes.first {
                    var nodeChain : IdentifiedArrayOf<MultiParentToggleGraphDataReducer.ToggleGraphDataNode> = []
                    return state.hasCircular(startNode: $0, checkNode: $0, nodeChain: &nodeChain)
                } == nil
            case .checkIDUnique:
                let count = nodes.map({$0.id}).count + relations.map({$0.id}).count
                let uniqueCount = Set(nodes.map({$0.id})).count + Set(relations.map({$0.id})).count
                return count == uniqueCount
            }
        }
    }
    public func checkIntegraty()->Bool{
        return IntegratyCriteria.allCases.first {
            !$0.passCriteria(state: self)
        } == nil
    }
    public func acceptNewRelation(childNode: MultiParentToggleGraphDataReducer.ToggleGraphDataNode
                                  ,parentNode: MultiParentToggleGraphDataReducer.ToggleGraphDataNode)->Bool{
        var nodeChain : IdentifiedArrayOf<MultiParentToggleGraphDataReducer.ToggleGraphDataNode> = []
        return !hasCircular(startNode: childNode,checkNode: parentNode,  nodeChain: &nodeChain)
    }


}
public struct MultiParentToggleGraphDataReducer : Reducer{
    @Dependency(\.context) var context
    @Dependency(\.mainQueue) var mainQueue
    public struct ToggleGraphDataNodeParentRelation: Identifiable, Equatable, Hashable{
        public var parentNodeID : ToggleGraphDataNode.ID
        public var childNodeID : ToggleGraphDataNode.ID
        public var isVisible : Bool
        public var id: ToggleGraphDataNode.ID{
            childNodeID + parentNodeID
        }
    }
    public struct ToggleGraphDataNode: Identifiable, Equatable{
        public typealias ID = String
        public var node : CyNode

        public var id: String{
            node.id
        }
        public enum RelationSetStatus : String, CaseIterable{
            case allVisible
            case mixed
            case noneVisible
            
            static func getRelationSetStatus(relationSet: Set<ToggleGraphDataNodeParentRelation>)->Self{
                if relationSet.isEmpty{
                    return .allVisible // all information is known
                }
                if relationSet.filter({
                    $0.isVisible
                }).count == relationSet.count{
                    return .allVisible
                }
                if relationSet.filter({
                    !$0.isVisible
                }).count == relationSet.count{
                    return .noneVisible
                }
                return .mixed
            }
            
            static func toggleUpStreamVisible(relationSet: Set<ToggleGraphDataNodeParentRelation>)->Bool{
                let relationSetStatus = getRelationSetStatus(relationSet: relationSet)
                switch relationSetStatus{
                case .allVisible, .mixed:
                    return true
                case .noneVisible:
                    fatalError()
                }
            }
            static func toggleDownStreamVisible(relationSet: Set<ToggleGraphDataNodeParentRelation>)->Bool{
                let relationSetStatus = getRelationSetStatus(relationSet: relationSet)
                switch relationSetStatus{
                case .allVisible:
                    return false
                case .mixed:
                    return true
                case .noneVisible:
                    return true
                }
            }
        }
        public enum NodeStatus: String, CaseIterable{
            case fullyExpanded
            case hidden
            case placeHolder
            case uptrace
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
                case .uptrace:
                    return .init(selector: "." + self.rawValue, style: .init(backgroundColor: "rgb(205,120,20)"))
                }
            }

            public var isVisible : Bool{return self != .hidden}
            
            static func getNodeStatus(upStreamRelation: Set<ToggleGraphDataNodeParentRelation>, downStreamRelation: Set<ToggleGraphDataNodeParentRelation>)->Self{
                let upStreamRelationSetStatus = RelationSetStatus.getRelationSetStatus(relationSet: upStreamRelation)
                let downStreamRelationSetStatus = RelationSetStatus.getRelationSetStatus(relationSet: downStreamRelation)
                switch upStreamRelationSetStatus{
                case .allVisible:
                    switch downStreamRelationSetStatus{
                    case .allVisible:
                        return .fullyExpanded
                    case .mixed:
                        return .uptrace
                    case .noneVisible:
                        return .toggle
                    }
                case .mixed:
                    return .placeHolder
                case .noneVisible:
                    switch downStreamRelationSetStatus{
                    case .allVisible:
                        if downStreamRelation.isEmpty{return .hidden}
                        else{fatalError()}
                    case .mixed:
                        fatalError()
                    case .noneVisible:
                        return .hidden
                    }
                }
            }

        }
    }
    public struct State: Equatable{
        static var defaultStyle = CyStyle.defaultStyle + ToggleGraphDataNode.NodeStatus.allCases.map({$0.cyStyle})
        public var joinCyGraphDataReducerState : CyGraphDataReducer.State = .init(joinCyCommandReducerState: .init()
                                                                                  , joinCyStyleReducerState: IdentifiedArray(uniqueElements: State.defaultStyle)
                                                                                  , cyGraph: .emptyGraph)
        public var nodes : IdentifiedArrayOf<ToggleGraphDataNode>
        public var relations : IdentifiedArrayOf<ToggleGraphDataNodeParentRelation>
        public var keyinString : String = ""
        public init(nodes: IdentifiedArrayOf<ToggleGraphDataNode> = []
        ,relations : IdentifiedArrayOf<ToggleGraphDataNodeParentRelation> = []) {
            self.nodes = nodes
            self.relations = relations
        }
        
    }
    public enum Action : Equatable{
        case toggleNode(nodeID: String)
        case joinActionCyGraphDataReducer(CyGraphDataReducer.Action)
        case newNode(parent : ToggleGraphDataNode?)
        case addParent(child: ToggleGraphDataNode, parent: ToggleGraphDataNode)
        case deleteRelation(relation: ToggleGraphDataNodeParentRelation)
        case deleteNode(node: ToggleGraphDataNode)
        case resetResponseData
        case updateCyGraph
        case keyinNodeID(context: ToggleGraphDataNode, keyin: String)
        case makeTemperaryConnection(child: ToggleGraphDataNode, parent: ToggleGraphDataNode)
    }
    private enum CancelID {
      case debounceKeyinNodeID
    }
    public var body: some Reducer<State, Action> {
        Scope(state: \.joinCyGraphDataReducerState, action: /Action.joinActionCyGraphDataReducer, child: {CyGraphDataReducer(initGraph: .emptyGraph
                                                                                                                             , initStyle: State.defaultStyle)})
        
        Reduce{state, action in
            switch action{
            case .keyinNodeID(let context,let value):
                state.keyinString = value
                if let node = state.nodes[id:value]{
                    let  debounceDuration : DispatchQueue.SchedulerTimeType.Stride = 1
                    return .send(.makeTemperaryConnection(child: context, parent: node))
                       // .debounce(id: CancelID.debounceKeyinNodeID, for: debounceDuration, scheduler: mainQueue)
                    //.debounce(for: CancelID.debounceKeyinNodeID, scheduler: debounceDuration, options: mainQueue)
                }
            case .makeTemperaryConnection(let child, let parent):
                let edge = CyEdge(id: "temp" + child.id + parent.id
                                  , label: "temp" + child.id + parent.id
                                  , classes : ["temp"]
                                  , source: child.id, target: parent.id)
                return .send(.joinActionCyGraphDataReducer(.addEdge(edge)))
            case .resetResponseData:
                state.joinCyGraphDataReducerState.joinCyCommandReducerState.cytoscapeJavascriptResponseData = nil
            case .deleteRelation(let relation):
                state.relations.remove(id: relation.id)
                return  .concatenate(
                    .send(.resetResponseData)
                    , .send(.updateCyGraph)
                    )
            case .deleteNode(let node):
                guard state.getDownStreamRelation(of: node).isEmpty else{fatalError()}
                let upStream = state.getUpStreamRelation(of: node)
                upStream.forEach {
                    state.relations.remove(id:$0.id)
                }
                state.nodes.remove(id:node.id)
                return  .concatenate(
                    .send(.resetResponseData)
                    , .send(.updateCyGraph)
                    )
            case .updateCyGraph:
                switch context{
                case .live, .preview:
                    return     .send(.joinActionCyGraphDataReducer(.update(state.cyGraph) ))
                case .test:
                    break
                }
                
            case .addParent(var child, let parent):
                if state.acceptNewRelation(childNode: child, parentNode: parent){
                    state.relations.append(.init(parentNodeID: parent.id, childNodeID: child.id, isVisible: true))
                    MultiParentToggleGraphDataReducer.State.upTraceRelationVisible(node: child, initialState: &state)
                    
                    return .send(.updateCyGraph)
                }
                else{
                    break
                }
            case .newNode(let parent):
                let newID = "\(Int.random(in: 0...1000))"
                var newNode = ToggleGraphDataNode(node: .init(id: newID, label: newID))
                state.nodes.append(newNode)
                if let parent = parent{
                    if state.acceptNewRelation(childNode: newNode, parentNode: parent){
                        state.relations.append(.init(parentNodeID: parent.id, childNodeID: newNode.id, isVisible: true))
                        MultiParentToggleGraphDataReducer.State.upTraceRelationVisible(node: newNode, initialState: &state)
                        return .send(.updateCyGraph)
                    }
                    else{
                        fatalError()
                    }
                }
                if parent == nil{
                    return  .concatenate(
                        .send(.resetResponseData)
                        , .send(.updateCyGraph)
                        )
                }
                else{
                    return .send(.updateCyGraph)
                }
            case .toggleNode(let id):
                
                let node = state.nodes[id:id]!
                let upStreamRelations = state.getUpStreamRelation(of: node)
                let downStreamRelations = state.getDownStreamRelation(of: node)
                let toggleUpStreamVisible = MultiParentToggleGraphDataReducer.ToggleGraphDataNode.RelationSetStatus.toggleUpStreamVisible(relationSet: Set(upStreamRelations))
                let toggleDownStreamVisible = MultiParentToggleGraphDataReducer.ToggleGraphDataNode.RelationSetStatus.toggleDownStreamVisible(relationSet: Set(downStreamRelations))
                upStreamRelations.forEach {
                    state.relations[id:$0.id]!.isVisible = toggleUpStreamVisible
                }
                downStreamRelations.forEach {
                    state.relations[id:$0.id]!.isVisible = toggleDownStreamVisible
                }
                let nodeStatusAfter = state.getNodeStatus(of: node)
                if nodeStatusAfter == .fullyExpanded{
                    MultiParentToggleGraphDataReducer.State.upTraceRelationVisible(node: node, initialState: &state)
                }
                if nodeStatusAfter == .toggle{
                    MultiParentToggleGraphDataReducer.State.downTraceRelationInVisible(node: node, initialState: &state)
                }
                return .send(.updateCyGraph)
                

            case .joinActionCyGraphDataReducer(let subAction):
                switch subAction{
                case .joinActionCyCommandReducer(let command):
                    
                    if case .cytoscapeEvent(let event) = command
                        , event.eventType.isClickOrTap
                        , event.isNode{
                        return .send(.toggleNode(nodeID: event.targetId) )
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
struct MultiParentToggleGraphDataNodeTestView: View {
    let responseData : CyJsResponse.CyJsResponseData?
    let rootStore : StoreOf<MultiParentToggleGraphDataReducer> = MultiParentToggleGraphDataReducer.store
    
    
    var body: some View {
        WithViewStore(self.rootStore, observe: {$0}) { viewStore in
            if let responseData = responseData{
                HStack{
                    Text(responseData.targetId)
                    if responseData.isNode{
                        let node = viewStore.nodes[id:responseData.targetId]!
                        VStack{
                            HStack{
                                Button {
                                    viewStore.send(.newNode(parent: node))
                                } label: {
                                    Text("add child")
                                }.buttonStyle(.plain)
                                Button {
                                    viewStore.send(.deleteNode(node: node))
                                } label: {
                                    Text("delete")
                                }.buttonStyle(.plain)
                                    .disabled(
                                        !viewStore.state.getDownStreamRelation(of: node).isEmpty
                                    )
                            }
                            HStack{
                                TextField("add parent by ID: ", text: viewStore.binding(get: \.keyinString
                                                                                        , send: {MultiParentToggleGraphDataReducer.Action.keyinNodeID(context: node, keyin: $0)})
)
                                
                      Button {
                          let parentNode = viewStore.nodes[id: viewStore.keyinString]!
                          viewStore.send(.addParent(child: node, parent: parentNode))
                          viewStore.send(.keyinNodeID(context: node, keyin: ""))
                      } label: {
                          Text("Done")
                      }
                      .disabled(
                          !buttonDoneEnable(keyinString: viewStore.keyinString
                                            , fromNode: node
                                            , state: viewStore.state)
                      )
//
                            }
                        }
                    }
                    if responseData.isEdge{
                        let relation = viewStore.relations[id:responseData.targetId]!
                        Button {
                            viewStore.send(.deleteRelation(relation: relation))
                        } label: {
                            Text("delete")
                        }.buttonStyle(.plain)
                            
                    }
                }
            }
            else{
                Text("Selected: None")
                    .opacity(0.5)
            }
        }
        
    }
    func buttonDoneEnable(keyinString: String, fromNode: MultiParentToggleGraphDataReducer.ToggleGraphDataNode
                          , state:  MultiParentToggleGraphDataReducer.State )->Bool{
        if let parentNode = state.nodes[id: keyinString]{
            return state.acceptNewRelation(childNode: fromNode, parentNode: parentNode)
        }
        else{
            return false
        }
    }
}

public struct MultiParentToggleGraphDataTestView: View {
    let store : StoreOf<MultiParentToggleGraphDataReducer> = MultiParentToggleGraphDataReducer.store
    let showColorIndicateViewRefresh : Bool
    public init(showColorIndicateViewRefresh: Bool = false){
        self.showColorIndicateViewRefresh = showColorIndicateViewRefresh
    }
    public var body: some View {
        
        Section
            {
                    WithViewStore(self.store, observe: {$0}) { viewStore in
                        CyLayoutPicker(store: store.scope(state: \.joinCyGraphDataReducerState, action: { childAction in
                            MultiParentToggleGraphDataReducer.Action.joinActionCyGraphDataReducer(childAction)
                        }))
                        if showColorIndicateViewRefresh{
                            Text("showColorIndicateViewRefresh")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(getRandomColor())
                        }
                        else{
                            EmptyView()
                        }
                        Button {
                            viewStore.send(.newNode(parent: nil))
                        } label: {
                            Text("add")
                        }

                        MultiParentToggleGraphDataNodeTestView(responseData: viewStore.joinCyGraphDataReducerState.joinCyCommandReducerState.cytoscapeJavascriptResponseData)

                    }
                    
                }
          

        
    }
}


struct MultiParentToggleGraphDataTestView_Previews: PreviewProvider {
    static let store : StoreOf<MultiParentToggleGraphDataReducer> = MultiParentToggleGraphDataReducer.store
    static var previews: some View {
        Form{
            MultiParentToggleGraphDataTestView(showColorIndicateViewRefresh: true)
            CyWKCoordinatorSwiftUIView()
                .frame(height: 300)
            
            Section("listener") {
                WKNotificationReducerSwiftUIView(store: store.scope(state: \.joinCyGraphDataReducerState.joinCyCommandReducerState.joinNotificationReducerState, action: {
                    MultiParentToggleGraphDataReducer.Action.joinActionCyGraphDataReducer(.joinActionCyCommandReducer(.joinActionNotificationReducer($0) )
                    )
                 })
                , showColorIndicateViewRefresh: true
                )
                
            }
        }
    }
}
