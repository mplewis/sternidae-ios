import XCTest

class AppTests: XCTestCase {

    func testHeadingToCardinal() {
        XCTAssertEqual(NavHelpers.headingToCardinal(degrees: 0), "N")
        XCTAssertEqual(NavHelpers.headingToCardinal(degrees: 90), "E")
        XCTAssertEqual(NavHelpers.headingToCardinal(degrees: 180), "S")
        XCTAssertEqual(NavHelpers.headingToCardinal(degrees: 270), "W")

        XCTAssertEqual(NavHelpers.headingToCardinal(degrees: 360), "N")
        XCTAssertEqual(NavHelpers.headingToCardinal(degrees: -180), "S")
        XCTAssertEqual(NavHelpers.headingToCardinal(degrees: 540), "S")
        
        XCTAssertEqual(NavHelpers.headingToCardinal(degrees: 45), "NE")
        XCTAssertEqual(NavHelpers.headingToCardinal(degrees: 45), "NE")
    }
    
}
