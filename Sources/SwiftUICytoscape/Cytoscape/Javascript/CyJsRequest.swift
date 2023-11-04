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
    case cyAddClass(id: String, class: String)
    case cyRemoveClass(id: String, class: String)
    case cyLayout(CyLayout)
    
    var jsString : String{
        switch self{
        case .cyLayout(let layout):
            return "cy.layout({name:'\(layout.rawValue)'}).run();"
        case .resetCanvas:
            let value = CyGraph.emptyGraph
            let style = CyStyle.defaultStyle
            return "clearCanvas();configCytoscape(\(value.jsonString), \(style.jsonString) );"
        case .initCytoscape(let value, let style):
#if os(iOS) || os(watchOS) || os(tvOS)
            return "configCytoscape(\(value.jsonString), \(style.jsonString) , true  , '\(value.layout.rawValue)' );"
#else
            return "configCytoscape(\(value.jsonString), \(style.jsonString) , false , '\(value.layout.rawValue)'  );"
#endif
        case .cyAddClass(let id,let className):
            return """
var j = cy.$('#\(id)');
j.addClass( '\(className)' );
"""
        case .cyRemoveClass(let id,let className):
            return """
var j = cy.$('#\(id)');
j.removeClass( '\(className)' );
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
            return """
cy.style()
.clear()
.fromJson(\(value.jsonString));
"""
        }
    }
}
