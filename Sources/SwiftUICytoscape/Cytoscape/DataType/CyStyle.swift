//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/6/19.
//

import Foundation

public extension Array where Element: Codable {

    var jsonString  : String {
       let jsonData = try! JSONEncoder().encode(self)
       return String(data: jsonData, encoding: .utf8)!
   }
}

public struct CyStyle : Codable, Equatable{
    
    public static var defaultStyle : [Self] = [.init(selector: "node", style: .init(content: "data(id)")) ,
                                           .init(selector: "edge", style: .init(curveStyle: "bezier"))
    ]
    public static var testStyle : [Self] = [.init(selector: "node", style: .init(content: "data(id)" , shape: .roundTriangle)) ,
                                           .init(selector: "edge", style: .init(curveStyle: "bezier"))
    ]
    
    public var selector : String
    public var style : CyStyleData
    
    public struct CyStyleData : Codable, Equatable{
        public var content : String?
        public var curveStyle : String?
        public var backgroundColor : String?
        public var shape : CyShape?
        
        public enum CodingKeys: String, CodingKey {
            case content
            case curveStyle = "curve-style"
            case backgroundColor = "background-color"
            case shape
        }
        
        public enum CyShape: String, Codable, Equatable {
            case ellipse, triangle
            case roundTriangle = "round-triangle"
            
        }
    }

    
}
