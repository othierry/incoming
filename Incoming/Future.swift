//
//  Future.swift
//  Incoming
//
//  Created by Olivier THIERRY on 06/09/15.
//  Copyright (c) 2015 Olivier THIERRY. All rights reserved.
//

import Foundation

let futureQueue = dispatch_queue_create(
  "com.future.queue",
  DISPATCH_QUEUE_CONCURRENT)

public enum State {
  case Pending, Resolved, Rejected
}

public class Future<A> {
  
  var value: A!
  var error: NSError?
  var chain: (then: [Void -> Void], fail: [Void -> Void]) = ([], [])
  var state: State = .Pending

  ///////////////////////////////////
  // DESIGNATED STATIC INITIALIZER //
  ///////////////////////////////////
  
  public static func incoming(f: Future<A> -> Void) -> Future<A> {
    let future = Future<A>()
    assert(NSThread.isMainThread(), "should be main thread")
    dispatch_async(futureQueue) {
      assert(!NSThread.isMainThread(), "should not be main thread")
      f(future)
    }
    return future
  }
  
  /////////////////////
  // [THEN] BINDINGS //
  /////////////////////
  
  public func then(f: A -> Void) -> Future<A> {
    prependThen { f(self.value) }
    return self
  }
  
  public func then<B>(f: A -> B) -> Future<B> {
    let future = Future<B>()
    prependThen { future.resolve(f(self.value)) }
    return future
  }

  public func then<B>(f: A -> Future<B>) -> Future<B> {
    let future = Future<B>()
    prependThen {
      f(self.value)
        .then(future.resolve)
        .fail(future.reject)
    }
    return future
  }

  /////////////////////
  // [FAIL] BINDINGS //
  /////////////////////

  public func fail(f: NSError? -> Void) -> Future<A> {
    prependFail { f(self.error) }
    return self
  }
  
  //////////////////
  // CONTROL FLOW //
  //////////////////

  public func resolve(value: A) {
    self.value = value
    
    if chain.then.isEmpty {
      state = .Resolved
    } else {
      dispatch_async(dispatch_get_main_queue()) {
        self.chain.then.removeLast()() // remove & invoke
        self.resolve(value)
      }
    }
  }
  
  public func reject(_ error: NSError? = nil) {
    self.error = error
    
    if chain.fail.isEmpty {
      state = .Rejected
    } else {
      dispatch_async(dispatch_get_main_queue()) {
        self.chain.fail.removeLast()() // remove & invoke
        self.reject(error)
      }
    }
  }
  
  /////////////
  // PRIVATE //
  /////////////

  private func prependThen(f: Void -> Void) {
    chain.then.insert(f, atIndex: 0)
    
    if state == .Resolved {
      resolve(value)
    }
  }

  private func prependFail(f: Void -> Void) {
    chain.fail.insert(f, atIndex: 0)
    
    if state == .Rejected {
      reject(error)
    }
  }

}