//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/10/9.
//

import Foundation

public enum CyJsRequest : Equatable {
    case initCytoscape(CyGraph,[CyStyle])
    case resetCanvas
    case cyAdd(CyGraph)
    case cyRemove(id: String)
    case cyStyle([CyStyle])
    case cyAddClass(id: String, class: String, layout: CyLayout)
    case cyRemoveClass(id: String, class: String, layout: CyLayout)
    case cyLayout(CyLayout)
    case cyUpdateLabel(id:String, label: String, layout: CyLayout)
    
    var jsString : String{
        switch self{
        case .cyLayout(let layout):
            return "cy.layout({name:'\(layout.rawValue)'}).run();"
        case .resetCanvas:
            let value = CyGraph.emptyGraph
            let style = CyStyle.defaultStyle
            //return "clearCanvas();configCytoscape(\(value.jsonString), \(style.jsonString) );"
            return "clearCanvas();" + CyJsRequest.initCytoscape(value, style).jsString
        case .initCytoscape(let value, let style):
#if os(iOS) || os(watchOS) || os(tvOS)
            return "configCytoscape(\(value.jsonString), \(style.jsonString) , true  , '\(value.layout.rawValue)' );"
#else
            return "configCytoscape(\(value.jsonString), \(style.jsonString) , false , '\(value.layout.rawValue)'  );"
#endif
        case .cyUpdateLabel(let id, let label, let layout):
            return """
var j = cy.$('#\(id)');
j.data( 'label' , '\(label)' );
cy.layout({name:'\(layout.rawValue)'}).run();
"""
        case .cyAddClass(let id,let className, let layout):
            return """
var j = cy.$('#\(id)');
j.addClass( '\(className)' );
cy.layout({name:'\(layout.rawValue)'}).run();
"""
        case .cyRemoveClass(let id,let className, let layout):
            return """
var j = cy.$('#\(id)');
j.removeClass( '\(className)' );
cy.layout({name:'\(layout.rawValue)'}).run();
"""
        case .cyAdd(let value):
            if value.edges.isEmpty && value.nodes.isEmpty{return ""}
            else{return "cy.add(\(value.jsonString));cy.layout({name:'\(value.layout.rawValue)'}).run();"}
        case .cyRemove(let id):
            return """
var j = cy.$('#\(id)');
cy.remove( j );
"""
        case .cyStyle(let value):
            let filtered = value.filter {
                $0.selector != "." && $0.selector != "#"
            }
            if filtered.isEmpty{
                return ""
            }
            return """
cy.style()
.clear()
.fromJson(\(filtered.jsonString));
"""
        }
    }
}
