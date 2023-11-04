//
//  File.swift
//
//
//  Created by MEI YIN LO on 2023/6/19.
//
import SwiftUI
import Foundation

public extension Array where Element: Codable {

    var jsonString  : String {
       let jsonData = try! JSONEncoder().encode(self)
       return String(data: jsonData, encoding: .utf8)!
   }
}
///
///cy.style().selector(`node[id='${nodeId}']`).style({
///'background-color': 'blue'
///}).update();
///
public struct CyStyle : Codable, Equatable, Identifiable, Hashable{
    public enum SystemID: String{
        case node
        case edge
        
        var name : String{
            return self.rawValue
        }
    }
    public static var edgeStyle : Self = .init(selector: "edge", style: .init(content: "data(label)", curveStyle: "bezier",backgroundColor: "rgb(255,255,0)",targetArrowShape:.triangle),  id:SystemID.edge.rawValue)
    public static var nodeStyle : Self = .init(selector: "node", style: .init(content: "data(label)",backgroundColor: "rgb(255,0,0)")
                                               , id:SystemID.node.rawValue)
    public static var defaultStyle : [Self] = [nodeStyle,
                                               edgeStyle
                                               //,.init(selector: ".unionGraphData", style: .init(backgroundColor: "red"))
                                               //,.init(selector: ".intersectGraphData", style: .init(backgroundColor: "green"))
                                                 
    ]
    public static var testStyle : [Self] = [.init(selector: "node", style: .init(content: "data(id)" , shape: .roundTriangle)) ,
                                           .init(selector: "edge", style: .init(curveStyle: "bezier"))
    ]
    
    public var selector : String
    public var style : CyStyleData
    public var name : String {return selector}
    public var id : String = UUID().uuidString
    
    public struct CyStyleData : Codable, Equatable, Hashable{
        public var content : String?
        public var curveStyle : String?
        public var backgroundColor : String?
        public var lineColor : String?
        public var borderColor : String?
        public var backgroundOpacity : String?
        public var shape : CyShape?
        public var targetArrowShape : CyTargetArrowShape = .none
        
        public enum CodingKeys: String, CodingKey {
            case content
            case curveStyle = "curve-style"
            case backgroundColor = "background-color"
            case lineColor = "line-color"
            case borderColor = "border-color"
            case backgroundOpacity = "background-opacity"
            case shape
            case targetArrowShape = "target-arrow-shape"
        }
        public enum CyTargetArrowShape: String, Codable, Equatable {
            //http://js.cytoscape.org/#style/edge-arrow
            case triangle
            case square
            case circle
            case diamond
            case chevron
            case none
        }
        public enum CyShape: String, Codable, Equatable {
            case ellipse, triangle
            case roundTriangle = "round-triangle"
            
        }
    }

    
}
public extension CyStyle{
    static func convertRGBToJavascriptString(color:Color)->String?{
        guard let components = color.cgColor!.components, components.count >= 3 else {
               return nil
           }
        
           let red = Int( components[0] * 255)
           let green = Int(components[1] * 255)
           let blue = Int( components[2] * 255)
        //print("rgb(\(red),\(green),\(blue))")
        return "rgb(\(red),\(green),\(blue))"
    }
    static func extractJavascriptRGBValues(from rgbString: String) -> Color {
        // Remove "rgb(" and ")" from the string and split by commas
        let numericString = rgbString.replacingOccurrences(of: "rgb(", with: "").replacingOccurrences(of: ")", with: "")
        let values = numericString.split(separator: ",")

        // Convert the string values to integers
        let rgb = values.compactMap {
            
            
            return CGFloat(floatLiteral: Double($0.trimmingCharacters(in: .whitespaces))! ) }

        return .init(red: rgb[0]/255
                     , green: rgb[1]/255, blue: rgb[2]/255 )
    }
}
