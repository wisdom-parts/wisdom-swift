import Foundation
import XCTest

import CreateML

@testable import Wisdom

protocol DoubleColumnTransformer {
    func transform(from old: String,
                   to new: String,
                   in table: inout MLDataTable) -> MLDataColumn<Double>
}

protocol DoubleColumnTransformerCharter {
    func found() -> DoubleColumnTransformer
}

struct ScaleDoubleColumn: DoubleColumnTransformer {
    struct Charter: DoubleColumnTransformerCharter {
        func found() -> DoubleColumnTransformer {
            return ScaleDoubleColumn(charter: self)
        }
        
        let newMin, newMax: Double
    }
    let newMin, newMax: Double
    
    init(charter: Charter) {
        newMin = charter.newMin
        newMax = charter.newMax
    }
    
    func transform(from oldName: String, to newName: String, in table: inout MLDataTable) -> MLDataColumn<Double> {
        let old: MLDataColumn<Double> = table[oldName]
        guard old.isValid else {
            return old
        }
        guard let min = old.min() else {
            return MLDataColumn<Double>()
        }
        guard let max = old.max() else {
            return MLDataColumn<Double>()
        }
        guard min != max else {
            return MLDataColumn<Double>()
        }
        let new = (old - min + newMin) / (max - min) * (newMax - newMin)
        table.addColumn(new, named: newName)
        return new
    }
}

struct TransformerError {
    let transformerDescription: String
    let oldColumnName, newColumnName: String
    let message: String
}

final class WisdomTests: XCTestCase {
    
    func testScaleDoubleColumn() throws {
        var table = try CreateML.MLDataTable(dictionary: [
            "name": ["fred", "john", "sally"],
            "age": [31.0, 24.0, 10.0]
            ]
        )
        let charter = ScaleDoubleColumn.Charter(newMin: 0.0, newMax: 1.0)
        let transformer = charter.found()
        let newCol = transformer.transform(from: "age", to: "scaledAge", in: &table)
        XCTAssert(newCol.isValid, "New column not valid: \(newCol)")
        XCTAssertEqual(newCol[0], 1.0)
        XCTAssertEqual(newCol[1], 0.666, accuracy: 0.001)
        XCTAssertEqual(newCol[2], 0.0)
    }
    
    static var allTests = [
        ("testScaleDoubleColumn", testScaleDoubleColumn),
    ]
}
