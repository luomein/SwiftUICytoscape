//
//  SwiftUIView.swift
//  
//
//  Created by MEI YIN LO on 2023/10/25.
//

import SwiftUI
import ComposableArchitecture

extension ToggleGraphDataReducer{
    static let store : StoreOf<ToggleGraphDataReducer> = .init(initialState: .init(), reducer: {ToggleGraphDataReducer()})
}
struct ToggleGraphDataReducer : ReducerProtocol{
    public struct ToggleGraphDataNode: Identifiable, Equatable{
        public var node : CyNode
        public var isExpanded : Bool = false
        public var parentNodeID : String?
        public var id: String{
            node.id
        }
        
    }
    public struct ToggleGraphDataNodeReducer : ReducerProtocol{
        typealias State = ToggleGraphDataNode
        public enum Action : Equatable{
            case toggle
            case addChild(from: ToggleGraphDataNode)
        }
        public var body: some ReducerProtocol<State, Action> {
            Reduce{state, action in
                switch action{
                case .toggle:
                    state.isExpanded.toggle()
                case .addChild:
                    break
                }
                return .none
            }
        }
    }
    public struct State: Equatable{
        
        public var joinCyGraphDataReducerState : CyGraphDataReducer.State = .init(joinCyCommandReducerState: .init(), joinCyStyleReducerState: IdentifiedArray(uniqueElements: CyStyle.defaultStyle), cyGraph: .emptyGraph)
        public var nodes : IdentifiedArrayOf<ToggleGraphDataNode> = []
        
        
        public var cyGraph : CyGraph{
            let filteredNodes  = nodes
                .filter({currentNode in
                    if let parentNodeID = currentNode.parentNodeID
                    {
                        print("isExpanded: ", nodes.first {
                            $0.id == parentNodeID
                        }!.isExpanded)
                        return nodes.first {
                            $0.id == parentNodeID
                        }!.isExpanded
                    }
                    else{
                        return true
                    }
                })
                
            return .init(nodes: filteredNodes.map({
                $0.node
            }), edges:
                filteredNodes.filter({
                    return $0.parentNodeID != nil
                })
                .map({currentNode in
                    return CyEdge.init(id: "e_" + currentNode.id, label: currentNode.id, source: currentNode.id, target: currentNode.parentNodeID!)
                })
            )
        }
    }
    public enum Action : Equatable{
        case joinActionToggleGraphDataNodeReducer(ToggleGraphDataNodeReducer.State.ID, ToggleGraphDataNodeReducer.Action)
        case joinActionCyGraphDataReducer(CyGraphDataReducer.Action)
        case add(parent : ToggleGraphDataNode?)
    }
    public var body: some ReducerProtocol<State, Action> {
        Scope(state: \.joinCyGraphDataReducerState, action: /Action.joinActionCyGraphDataReducer, child: {CyGraphDataReducer(initGraph: .emptyGraph
                                                                                                                             , initStyle: CyStyle.defaultStyle)})
        
        Reduce{state, action in
            switch action{
            case .add(let parent):
                let newID = "\(Int.random(in: 0...1000))"
                let newNode = ToggleGraphDataNode(node: .init(id: newID, label: newID), isExpanded: false, parentNodeID: parent?.id ?? nil)
                state.nodes.append(newNode)
                return .send(.joinActionCyGraphDataReducer(.update(state.cyGraph) ))
            case .joinActionToggleGraphDataNodeReducer(_, let subAction):
                switch subAction{
                case .toggle:
                    return .send(.joinActionCyGraphDataReducer(.update(state.cyGraph) ))
                case .addChild(let node):
                    return .send(.add(parent: node))
                }
            default:
                break
            }
            return .none
        }
        .forEach(\.nodes, action: /Action.joinActionToggleGraphDataNodeReducer, element: {ToggleGraphDataNodeReducer()})
    }
}
struct ToggleGraphDataNodeTestView: View {
    let store : StoreOf<ToggleGraphDataReducer.ToggleGraphDataNodeReducer>
    var body: some View {
        WithViewStore(self.store, observe: {$0}) { viewStore in
            DisclosureGroup( viewStore.id
                             , isExpanded: viewStore.binding(get:  \.isExpanded, send: .toggle )) {
                Button {
                    viewStore.send(.addChild(from: viewStore.state))
                } label: {
                    Text("add child")
                }
            }
            
        }
    }
}
public struct ToggleGraphDataTestView: View {
    let store : StoreOf<ToggleGraphDataReducer> = ToggleGraphDataReducer.store
    public init(){}
    public var body: some View {
        WithViewStore(self.store, observe: {$0}) { viewStore in
            Section{
                Button {
                    viewStore.send(.add(parent: nil))
                } label: {
                    Text("add")
                }
                ForEachStore(
                    self.store.scope(state: \.nodes, action: { .joinActionToggleGraphDataNodeReducer($0, $1) })
                ) { subStore in
                    ToggleGraphDataNodeTestView(store: subStore)
                }
            }
            .background {
                WKNotificationReducerSwiftUIView(store: store.scope(state: \.joinCyGraphDataReducerState.joinCyCommandReducerState.joinNotificationReducerState, action: {
                    ToggleGraphDataReducer.Action.joinActionCyGraphDataReducer(.joinActionCyCommandReducer(.joinActionNotificationReducer($0) ) )
                    //CyGraphReducer.Action.joinActionNotificationReducer($0)
                    
                }))
            }
        }
    }
}

struct ToggleGraphDataTestView_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            ToggleGraphDataTestView()
            CyWKCoordinatorSwiftUIView()
                .frame(height: 300)
        }
    }
}
