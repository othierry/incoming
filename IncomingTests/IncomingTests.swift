//
//  IncomingTests.swift
//  IncomingTests
//
//  Created by Olivier THIERRY on 15/06/15.
//  Copyright (c) 2015 Olivier THIERRY. All rights reserved.
//

import UIKit
import XCTest

class IncomingTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
  
  func all(promises: [Promise]) -> Promise {
    let p = Promise()
    p.resolve(promises.map { $0.value } as! AnyObject)
    return p
  }
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")

      
//      let promise = Future<Void>()
//      
//      promise.then {
//        print("Hello ")
//      }.then { Void -> String in
//        return "Olivier"
//      }.then { name -> Future<Int> in
//        print("\(name). I am ")
//        let promise = Future<Int>()
//        promise.resolve(42)
//        return promise
//      }.then { int in
//        println("\(int) years old.")
//      }
//      
//      promise.resolve()
     
      Future<String>.incoming { future in
        future.resolve("olivier")
      }.then { name -> Int in
        print(name)
        return 25
      }.then { age -> Future<(Int, String, Bool)> in
        println(" is \(age) years old")
        return Future.incoming { future in
          future.resolve(42, "Olivier", true)
        }
      }.then { a, b, c in
        println("\(a), \(b), \(c)")
      }
      
//      let promise = Future<(Int?, Int, [String])>()
//      
//      promise.then { (d: Int?, e: Int, f: [String]) -> String in
//        println("\(d) \(e) \(f)")
//        return "Olivier"
//      }.then { _ -> Future<Int> in
//        let f = Future<Int>()
//        f.reject(NSError(domain: "", code: 42, userInfo: [:]))
//        return f
//      }.then { x in
//        println("X = \(x)")
//      }.fail { (e: NSError?) in
//        println("failed \(e)")
//      }
//      
//      let a: Int? = 42
//      
//      promise.resolve(a, 42, [""])
      
//      let promise = Future<(Int?, String, [String])>()
//      
//      promise.then { (a: Int?, b: String, c: [String]) -> String in
//        println("\(a) \(b) \(c)")
//        return "Olivier"
//        }.then { _ -> Future<Int> in
//          let f = Future<Int>()
//          //  f.reject()
//          return f
//      }
//      
//      promise.resolve(42, "Oli", ["vier"])


      //let f = Future<String>()
      
      
//      let p1 = Promise()
//      p1.resolve("Olivier")
//      
//      let p2 = Promise()
//      p2.resolve("Thierry")
//      
//      all([p1, p2]).then { (names: AnyObject) in
//        println("got names: \(names as! [String])")
//        }.fail { error in println("error: \(error)") }
      
//      let promise = Promise()
//      
//      promise.then { (xs: [Int]) -> [String?] in
//        return ["oli", "vier"]
//        }.then { (names: [String?]) in
//          println("got \(names)")
//        }.fail { error in
//          println("error: \(error)")
//      }
//      
//      promise.resolve([1,2])

    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
