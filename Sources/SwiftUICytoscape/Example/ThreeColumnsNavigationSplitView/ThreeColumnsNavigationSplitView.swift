//
//  SwiftUIView.swift
//  
//
//  Created by MEI YIN LO on 2023/10/10.
//

import SwiftUI
import ComposableArchitecture

public struct ThreeColumnsNavigationSplitView: View {
    @State var columnVisibility: NavigationSplitViewVisibility = .all
    @State var selectedIds : Set<String> = []
    //@State var path: [Route] = []
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var store : StoreOf<GraphDataCytoscapeReducer> = .init(initialState: .init()
                                                          , reducer:{GraphDataCytoscapeReducer()} )
    public init(){
        
    }
//    enum Route {
//        case link1, link2
//    }
    enum SubView : String{
        case graph
        case node
        case edge
        
        @ViewBuilder
        func getNavLink()->NavigationLink<Text,Never>{
            NavigationLink(value: self.rawValue) {
                Text(self.rawValue)
                
            }
        }
    }
    public var body: some View {
        WithViewStore(self.store, observe: {$0}) { viewStore in
            NavigationSplitView(
                columnVisibility: $columnVisibility
            ) {
                List(selection:$selectedIds){
                    if horizontalSizeClass == .compact{
                        Button {
                            selectedIds = Set([SubView.graph.rawValue])
                        } label: {
                            Text("test")
                        }
                        
                        SubView.graph.getNavLink()
//                        Button("Hide sidebar") {
//                            print(horizontalSizeClass)
//                            withAnimation {
//                                columnVisibility = .doubleColumn //.detailOnly
//                            }
//                        }
                    }
                    DisclosureGroup {
//                        Button {
//                            viewStore.send(.addNode(.init(data: .init(id: UUID().uuidString, label: "\(Int.random(in: 0...1000))"))))
//                        } label: {
//                            Text("add")
//                        }

                            ForEach(viewStore.graph.nodes){node in
//                                NavigationLink(value: node.id) {
//                                    Text(node.data.label)
//                                }
//
                                Button {
                                    selectedIds = Set([node.id])
                                } label: {
                                    Text(node.data.label)
                                        
                                }
                                //.tag(node.id)
                                .buttonStyle(.plain)
                            }
                        //}
                    } label: {
                        HStack{
                            //Text("node")
                            SubView.node.getNavLink().buttonStyle(.plain)
                            Spacer()
                            Text("\(viewStore.graph.nodes.count)")
                        }
                    }
                    DisclosureGroup {
                        
                        ForEach(viewStore.graphStyle){item in
                                NavigationLink(value: item.id) {
                                    Text(item.name)
                                }
                                
                            }
                        //}
                    } label: {
                        Text("style")
                    }

                }
            } content: {
                Form{
                    if let id = selectedIds.first{
                        if id == SubView.node.rawValue{
                            Button {
                                viewStore.send(.joinActionGraphStyleReducer(CyStyle.SystemID.node.rawValue, .setAttribute(attribute: \.backgroundColor, value: "blue")) )
                            } label: {
                                Text("blue")
                            }

                        }
                        Text(Array(selectedIds).joined(separator: ", "))
                    }
                    
                }
                //Form{
                        
                   // NavigationStack {
//                        VStack{
//                            if selectedIds.count > 0 {
//                                Text(Array(selectedIds).joined(separator: ", "))
//                            }
//                            NavigationLink("Link1", value: Route.link1)
//                            NavigationLink("Link2", value: Route.link2)
//                        }
//
                           //}

                //}
                
                
            } detail: {
                GraphDataCytoscapeReducerTestView(store: store)
//                NavigationStack(path:$path) {
//                    GraphDataCytoscapeReducerTestView(store: store)
//                        .navigationDestination(for: Route.self) { route in
//                            switch route {
//                            case .link1:
//                                Text("link1")
//                            case .link2:
//                                Text("link2")
//                            }
//                        }
//                }
//
            }
        }
    }
}

struct ThreeColumnsNavigationSplitView_Previews: PreviewProvider {
    static var previews: some View {
        ThreeColumnsNavigationSplitView()
    }
}
