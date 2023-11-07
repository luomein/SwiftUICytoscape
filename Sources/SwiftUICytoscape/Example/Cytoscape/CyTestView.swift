//
//  SwiftUIView.swift
//  
//
//  Created by MEI YIN LO on 2023/6/15.
//

import SwiftUI
import ComposableArchitecture
import WebKit
import IdentifiedCollections

extension CyTestViewReducer{
    public static var store : StoreOf<Self> = .init(initialState: .init()
                                                         , reducer: {Self()})
}
public struct CyTestViewReducer : Reducer{
    public struct SimpleCyClass : Identifiable, Equatable, Hashable{
        public let name = "\(Int.random(in: 0...1000))"
        public var id: String{return name}
        public var items : Set<String> = []
    }
    public struct State: Equatable, Hashable{
        public var joinCyCommandReducerState : CyCommandReducer.State = .init()
        //public var joinCyStyleReducerState : CyStyleReducer.State = .nodeStyle
        public var styles : IdentifiedArrayOf<CyStyleReducer.State> = .init(uniqueElements: CyStyle.defaultStyle)
        public var classes : IdentifiedArrayOf<SimpleCyClass> = []
        public var layout: CyLayout = .fcose
        public init(){}
    }
    public enum Action : Equatable{
        case joinCyCommandReducerAction(CyCommandReducer.Action)
        case joinCyStyleReducerAction(CyStyleReducer.State.ID, CyStyleReducer.Action)
        case addClass
        case addStyle
        case toggleClass(classID: String, itemID: String)
        case setLayout(CyLayout)
        case randomAdd(layout: CyLayout)
        case queueJS(CyJsRequest)
    }
    public init(){}
    public var body: some Reducer<State, Action> {
        Scope(state: \.joinCyCommandReducerState, action: /Action.joinCyCommandReducerAction, child: {CyCommandReducer()})
        
        Reduce{state, action in
            switch action{
            case .toggleClass(let classID , let itemID):
                if state.classes[id: classID]!.items.contains(itemID){
                    state.classes[id: classID]!.items.remove(itemID)
                    return .send( .queueJS(.cyRemoveClass(id: itemID, class: classID, layout: state.layout)) )
                }
                else{
                    state.classes[id: classID]!.items.insert(itemID)
                    return .send(.queueJS(.cyAddClass(id: itemID, class: classID, layout: state.layout)) )
                }
            case .setLayout(let value):
                state.layout = value
                //viewStore.send(.queueJS(.cyLayout(value)))
                return .send(.queueJS(.cyLayout(value)))
            case .addStyle:
                state.styles.append(CyStyle.init())
            case .addClass:
                state.classes.append(.init())
            case .randomAdd(let layout):
                let length = 10
                var nodes : [CyNode] = []
                var edges : [CyEdge] = []
                for _ in 1...length {
                    let r = "\(Int.random(in: 0...10000))"
                    nodes.append(.init(id: r, label: r))
                }
                for _ in 1...length{
                    let e = "e\(Int.random(in: 0...10000))"
                    
                    edges.append(.init(id: e, label: e, source: nodes[Int.random(in: 0..<length)].id, target: nodes[Int.random(in: 0..<length)].id))
                }
                return .send(.queueJS(.cyAdd(.init(nodes:nodes, edges:edges, layout:layout))))
            case .joinCyStyleReducerAction:
                return .send(.joinCyCommandReducerAction(.queueJS(.cyStyle(state.styles.elements))))
            case .queueJS(let value):
                return .send(.joinCyCommandReducerAction(.queueJS(value)))
                    
            default:
                break
            }
            return .none
        }
        .forEach(\.styles, action: /Action.joinCyStyleReducerAction, element: {CyStyleReducer()})
        //Scope(state: \.joinCyStyleReducerState, action: /Action.joinCyStyleReducerAction, child: {CyStyleReducer()})
    }
}
public struct CyTestView: View {
    let store : StoreOf<CyTestViewReducer>
    @State var selectedItemLabel : String = ""
    
    public init(store: StoreOf<CyTestViewReducer>) {
        self.store = store
    }

   
    public var body: some View {
        WithViewStore(self.store, observe: {$0}) { viewStore in
            //Form{
                
            Section{
                //CyStyleReducerView(store: store.scope(state: \.joinCyStyleReducerState, action: {CyTestViewReducer.Action.joinCyStyleReducerAction($0)}))
                ForEachStore(
                    self.store.scope(state: \.styles
                                     , action: { .joinCyStyleReducerAction($0, $1) })
                ) { subStore in
                    CyStyleReducerView(store: subStore)
                }
            }header: {
                HStack{
                    Text("Style")
                    Button {
                        viewStore.send(.addStyle)
                    } label: {
                        Text("add")
                    }
                }
            }
            Section{
                ForEach(viewStore.state.classes) { c in
                    Text(c.name)
                }
            }header: {
                HStack{
                    Text("Class")
                    Button {
                        viewStore.send(.addClass)
                    } label: {
                        Text("add")
                    }

                }
            }

            Section("Selected Item") {
                if let cytoscapeJavascriptResponseData = viewStore.state.joinCyCommandReducerState.cytoscapeJavascriptResponseData{
                    Text(cytoscapeJavascriptResponseData.targetId)

                    
                    TextField(text: $selectedItemLabel, label: {Text("label")})
                        
                        .onChange(of: selectedItemLabel) { newValue in
                            viewStore.send(
                                .queueJS(.cyUpdateLabel(id: cytoscapeJavascriptResponseData.targetId, label: newValue, layout: viewStore.state.layout))
                            )
                        }
                    DisclosureGroup {
                        ForEach(viewStore.classes) { c in
                            HStack{
                                Button {
                                    viewStore.send(.toggleClass(classID: c.id, itemID: cytoscapeJavascriptResponseData.targetId))
                                } label: {
                                    if c.items.contains(cytoscapeJavascriptResponseData.targetId){
                                        Text(Image(systemName: "checkmark"))
                                            .foregroundColor(.green)
                                    }
                                    else{
                                        Text(Image(systemName: "checkmark"))
                                            .foregroundColor(.gray)
                                            .opacity(0.3)
                                    }
                                }

                                Text(c.name)
                            }
                        }
                    } label: {
                        Text("class")
                    }

                }
                else{
                    Text("empty")
                }
            }
            .onChange(of: viewStore.state.joinCyCommandReducerState.cytoscapeJavascriptResponseData?.targetId, perform: { newValue in
                if let cytoscapeJavascriptResponseData = viewStore.state.joinCyCommandReducerState.cytoscapeJavascriptResponseData{
                    selectedItemLabel = cytoscapeJavascriptResponseData.targetLabel
                }
            })
               
            //}

        }
    }
}
public struct CyTestGraphHeader: View {
    let store : StoreOf<CyTestViewReducer>
    
    public init(store: StoreOf<CyTestViewReducer>) {
        self.store = store
    }
    public var body: some View {
        WithViewStore(store, observe: {$0}) { viewStore in
            HStack{
                Text("Graph")
                Button {
                    viewStore.send(.randomAdd(layout: viewStore.layout))
                } label: {
                    Text("add")
                }
                Button {
                    viewStore.send(.queueJS(.resetCanvas))
                } label: {
                    Text("reset")
                }
                
                Picker(selection:
                        viewStore.binding( get: \.layout,
                                           send: { value in
                        .setLayout(value)
                }
                ))
                {
                    ForEach(CyLayout.allCases) { value in
                        Text(value.rawValue)
                            .tag(value)
                    }
                } label: {
                    Text("layout")
                }
//                .onChange(of: layout) { newValue in
//                    viewStore.send(.queueJS(.cyLayout(layout)))
//                }
            }
        }
    }
}
struct CyTestView_Previews: PreviewProvider {
    static var store : StoreOf<CyTestViewReducer> = CyTestViewReducer.store
    
    static var previews: some View {
        Form{
            CyTestView(store: store)
            Section {
                CyWKWrapperView(store: store.scope(state: \.joinCyCommandReducerState.joinNotificationReducerState
                                                   , action: {
                    CyTestViewReducer.Action.joinCyCommandReducerAction(.joinActionNotificationReducer($0))
                }))
                .frame(height: 250)
            } header: {
                CyTestGraphHeader(store: store)
            }

            
        }
    }
}
