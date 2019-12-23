import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(wisdom_swiftTests.allTests),
    ]
}
#endif
