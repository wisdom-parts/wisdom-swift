import XCTest
@testable import Wisdom

final class wisdom_swiftTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        // XCTAssertEqual(wisdom_swift().text, "Hello, World!")
        class A {}
        class B {}

        print(B.self.identifier)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
