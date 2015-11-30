//
//  MilkCocoaTests.swift
//  MilkCocoaTests
//
//  Created by HIYA SHUHEI on 2015/11/03.
//  Copyright © 2015年 Shuhei Hiya. All rights reserved.
//

import XCTest
@testable import MilkCocoa

class MilkCocoaTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let milkcocoa = MilkCocoa(app_id: "vuei9dh5mu3", host: "vuei9dh5mu3.mlkcca.com")
        let ds = milkcocoa.dataStore("aaa")
        ds.on("send", callback: {params in
            NSLog("Recv Send")
        })
        ds.send([
            "content":"Hello"])
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
