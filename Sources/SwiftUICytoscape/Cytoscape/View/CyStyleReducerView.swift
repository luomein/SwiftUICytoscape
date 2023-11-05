//
//  SwiftUIView.swift
//  
//
//  Created by MEI YIN LO on 2023/10/11.
//

import SwiftUI
import ComposableArchitecture

public struct CyStyleReducerView: View {

    
    let store : StoreOf<CyStyleReducer>
    public init(store: StoreOf<CyStyleReducer>) {
        self.store = store
    }
    var colorPicker: some View{
        
        
            WithViewStore(self.store, observe: {$0}) { viewStore in
                ColorPicker(selection: viewStore.binding(get: {
                    if let rgb = $0.style[keyPath: colorPickerAttribute]?.hasPrefix("rgb"), rgb == true {
                        let parser = JavascriptRGBColorParserPrinter()
                        var colorString = $0.style[keyPath: colorPickerAttribute]!
                        return try!parser.parse(colorString.utf8).color
//                        return CyStyle.extractJavascriptRGBValues(from: $0.style[keyPath: colorPickerAttribute]!)
                    }
                    else{
                        if let colorString = $0.style[keyPath: colorPickerAttribute]{
                            return Color(.init(stringLiteral: colorString))
                        }
                        else{
                            return Color.black
                        }
                        
                    }
                }, send: {color in
                    CyStyleReducer.Action.setColor(attribute: colorPickerAttribute,color)
                }
                                                         
                                                        ), label: {
                    let colorAttributes : [WritableKeyPath<CyStyle.CyStyleData,String?>] = [\.backgroundColor, \.lineColor]
                    Picker(selection: $colorPickerAttribute) {
                        ForEach(colorAttributes, id: \.self) { a in
                            Text(a.customDumpDescription.split(separator: ".").last!)
                                .tag(a)
                        }
                    } label: {
                        Text("color")
                    }
                })
            }
        
        
    }
    var nodeShapePicker : some View{
        WithViewStore(self.store, observe: {$0}) { viewStore in
            Picker(selection:
                    viewStore.binding( get: {
                $0.style.shape ?? .none
            },
                                       send: { value in
                CyStyleReducer.Action.setShape(value)
            }))
            {
                Text("").tag(CyStyle.CyStyleData.CyShape.none)
                ForEach(CyStyle.CyStyleData.CyShape.allCasesExcluseNone) { value in
                    Text(value.rawValue)
                        .tag(value)
                }
            } label: {
                Text("shape")
            }
        }
    }
    var contentPicker : some View{
        WithViewStore(self.store, observe: {$0}) { viewStore in
            Picker(selection:
                    viewStore.binding( get: {
                CyStyle.CyStyleData.CyContentExpression.init(rawValue: $0.style.content ?? CyStyle.CyStyleData.CyContentExpression.none.rawValue) ?? .none
            },
                                       send: { value in
                if value == .none{ return CyStyleReducer.Action.setAttribute(attribute: \.content, value: nil) }
                else{
                    return CyStyleReducer.Action.setAttribute(attribute: \.content, value: value.rawValue)
                }
                    //.setContent(value)
                    //.setAttribute(attribute: \.content, value: value.rawValue)
            }))
            {
                Text("").tag(CyStyle.CyStyleData.CyContentExpression.none)
                ForEach(CyStyle.CyStyleData.CyContentExpression.allCasesExcluseNone) { value in
                    Text(value.rawValue)
                        .tag(value)
                }
            } label: {
                Text("content")
            }
        }
    }
    @State var selectorValue : String = ""
    var selector : some View{
        WithViewStore(self.store, observe: {$0}) { viewStore in
            HStack{
                Picker(selection:
                        viewStore.binding( get: {
                    //CyStyle.CyStyleData.CyContentExpression.init(rawValue: $0.style.content ?? CyStyle.CyStyleData.CyContentExpression.none.rawValue) ?? .none
                    CyStyle.CyStyleSelector(rawValue: $0.selector).selectorType
                },
                                           send: {
                    selectorValue = ""
                   
                        let selector = CyStyle.CyStyleSelector(selectorType: $0)
                        return CyStyleReducer.Action.setSelector(selector.outputValue)
                   
                }))
                {
                    
                    ForEach(CyStyle.CyStyleSelectorType.allCases) { value in
                        Text(value.rawValue)
                            .tag(value)
                    }
                } label: {
                    Text("selector")
                        
                }
                if CyStyle.CyStyleSelector.hasValueSelectorType.contains( CyStyle.CyStyleSelector(rawValue: viewStore.selector).selectorType){
                    TextField("value", text: $selectorValue)
                        .onChange(of: selectorValue){newValue in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                let selectorType = CyStyle.CyStyleSelector(rawValue: viewStore.selector).selectorType
                                let selector = CyStyle.CyStyleSelector(selectorType: selectorType, value: selectorValue)
                                viewStore.send( CyStyleReducer.Action.setSelector(selector.outputValue) )
                            }
                        }
                }
            }
        }
    }
    @State var colorPickerAttribute : WritableKeyPath<CyStyle.CyStyleData,String?> = \.backgroundColor
    public var body: some View {
        
            DisclosureGroup {
                List{
                    selector
                    colorPicker
                    nodeShapePicker
                    contentPicker
                }
            } label: {
                Text("style")
            }

            
        
    }
}
