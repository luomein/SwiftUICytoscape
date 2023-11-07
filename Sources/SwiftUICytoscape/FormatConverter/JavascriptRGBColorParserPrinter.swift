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
        public init(color: UIColor){
//            guard let components = color.cgColor.components, components.count >= 3 else {
//                   fatalError()
//               }
            //https://stackoverflow.com/questions/28644311/how-to-get-the-rgb-code-int-from-an-uicolor-in-swift
            var fRed : CGFloat = 0
            var fGreen : CGFloat = 0
            var fBlue : CGFloat = 0
            var fAlpha: CGFloat = 0
            guard color.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha)  else{fatalError()}
             
            self.r255 = Int(fRed * 255.0)
            self.g255 = Int(fGreen * 255.0)
            self.b255 = Int(fBlue * 255.0)
                        //let iAlpha = Int(fAlpha * 255.0)

                        //  (Bits 24-31 are alpha, 16-23 are red, 8-15 are green, 0-7 are blue).
                        //let rgb = (iAlpha << 24) + (iRed << 16) + (iGreen << 8) + iBlue
                        //return rgb
                    
            
//            self.r255 = Int( components[0] * 255)
//            self.g255 = Int(components[1] * 255)
//            self.b255 = Int( components[2] * 255)
        }
        public var color : Color{
            return .init(red: Double(r255)/255.0
                         , green: Double(g255)/255.0
                         , blue: Double(b255)/255.0)
        }
        public static func getRandomColor()->Color{
            let color = Self.init(r255: Int.random(in: 0...255)
                                  , g255: Int.random(in: 0...255)
                                  , b255: Int.random(in: 0...255))
            return color.color
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

