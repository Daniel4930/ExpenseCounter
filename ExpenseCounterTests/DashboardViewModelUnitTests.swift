//
//  DashboardViewModelUnitTests.swift
//  ExpenseCounterTests
//
//  Created by Daniel Le on 6/14/25.
//

import XCTest
@testable import ExpenseCounter

final class DashboardViewModelUnitTests: XCTestCase {
    func testIncrementMonth() {
        let viewModel = DashboardViewModel()
        let date = DateComponents(calendar: .current, year: 2025, month: 12, day: 1).date!
        
        let incrementedDate = viewModel.incrementMonth(date: date)
        
        let expectedDate = DateComponents(calendar: .current, year: 2026, month: 1, day: 1).date!
        
        XCTAssertEqual(incrementedDate, expectedDate)
    }
    
    func testDecrementMonth() {
        let viewModel = DashboardViewModel()
        let date = DateComponents(calendar: .current, year: 2025, month: 1, day: 1).date!
        
        let incrementedDate = viewModel.decrementMonth(date: date)
        
        let expectedDate = DateComponents(calendar: .current, year: 2024, month: 12, day: 1).date!
        
        XCTAssertEqual(incrementedDate, expectedDate)
    }
    
    func testMonthOutOfBounce_whenFutureDate_shoudlReturnTrue() {
        let viewModel = DashboardViewModel()
        let futureDate = Calendar.current.date(byAdding: .month, value: 1, to: Date())!
        
        let isOutOfBounce = viewModel.isMonthOutOfBounds(from: futureDate)
        
        XCTAssertTrue(isOutOfBounce)
    }
    
    func testMonthOutOfBounce_whenpPastDate_shoudlReturnFalse() {
        let viewModel = DashboardViewModel()
        let futureDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        
        let isOutOfBounce = viewModel.isMonthOutOfBounds(from: futureDate)
        
        XCTAssertFalse(isOutOfBounce)
    }
}
