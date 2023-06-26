import XCTest
@testable import SwiftUICytoscape

final class SwiftUICytoscapeTests: XCTestCase {
    func testExample() throws {
        let graph = SetDBGraphData(nodes: [.init(data: .init(id: "a", label: "adfsd"))], edges: [])
        print(graph.jsonString)
    }
    func testStyleJson(){
//        let jsonData = try! JSONEncoder().encode(CyStyle.defaultStyle)
//        print(String(data: jsonData, encoding: .utf8)!)
        print(CyStyle.testStyle.jsonString)
    }
}
