//
//  JavascriptParserPrintTests.swift
//  
//
//  Created by MEI YIN LO on 2023/11/5.
//

import XCTest
import Parsing
import SwiftUI
import SwiftUICytoscape

final class JavascriptParserPrintTests: XCTestCase {

    func test()throws{
        let parser = JavascriptRGBColorParserPrinter()
        var utf8 = try parser.print(JavascriptRGBColorParserPrinter.ColorBridge.init(r255: 255, g255: 0, b255: 0 ))
        try print(String(utf8))
        try print(parser.parse(&utf8))
    }

}
