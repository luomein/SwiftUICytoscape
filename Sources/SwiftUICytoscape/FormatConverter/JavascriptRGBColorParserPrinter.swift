//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/11/5.
//

import Foundation
import SwiftUI
import Parsing

public struct JavascriptRGBColorParserPrinter: ParserPrinter {
    public struct ColorBridge{
        var r255:Int
        var g255:Int
        var b255:Int
        public init(r255: Int, g255: Int, b255: Int) {
            self.r255 = r255
            self.g255 = g255
            self.b255 = b255
        }
        public init(color: Color){
            guard let components = color.cgColor!.components, components.count >= 3 else {
                   fatalError()
               }
            
            self.r255 = Int( components[0] * 255)
            self.g255 = Int(components[1] * 255)
            self.b255 = Int( components[2] * 255)
        }
        public var color : Color{
            return .init(red: Double(r255)/255.0
                         , green: Double(g255)/255.0
                         , blue: Double(b255)/255.0)
        }
    }
    public init(){}
    public var body: some ParserPrinter<Substring.UTF8View, ColorBridge> {
        ParsePrint(.memberwise(ColorBridge.init(r255:  g255:  b255: ))){
            "rgb(".utf8
            Int.parser()
            //Prefix { $0 != "," || $0 != " " }.map( { Int($0)   })
            //Double.parser().map({$0/255})
            ",".utf8
            Int.parser()
            //Prefix { $0 != "," || $0 != " " }.map( { Int($0)  })
            //Double.parser().map({$0/255})
            ",".utf8
            Int.parser()
            //Prefix { $0 != "," || $0 != " " }.map( { Int($0)  })
            //Double.parser().map({$0/255})
            ")".utf8
        }
    }
}

