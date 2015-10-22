//
//  Incoming.swift
//  Incoming
//
//  Created by Olivier THIERRY on 15/06/15.
//  Copyright (c) 2015 Olivier THIERRY. All rights reserved.
//

import Foundation

let serialQueue = dispatch_queue_create(
  "promise.incoming.serial",
  DISPATCH_QUEUE_SERIAL)

public enum PromiseConcurrencyType {
  case Concurrent, Serial
}

public func incoming() -> Promise {
  return Promise()
}

public func incoming(
  _ concurrencyType: PromiseConcurrencyType = .Concurrent,
  closure: Promise -> Void) -> Promise
{
  switch concurrencyType {
  case .Concurrent:
    return incoming_dispatch(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), closure)
  case .Serial:
    return incoming_dispatch(serialQueue, closure)
  }
}

private func incoming_dispatch(queue: dispatch_queue_t, closure: Promise -> Void) -> Promise {
  let promise = incoming()
  closure(promise)
  return promise
}