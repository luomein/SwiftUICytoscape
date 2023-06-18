import XCTest
@testable import SwiftUICytoscape

final class SwiftUICytoscapeTests: XCTestCase {
    func testExample() throws {
        let graph = CyGraphData(nodes: [.init(data: .init(id: "a", label: "adfsd"))], edges: [])
        print(graph.jsonString)
    }
}
