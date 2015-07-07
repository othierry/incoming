//
//  Incoming.swift
//  Incoming
//
//  Created by Olivier THIERRY on 15/06/15.
//  Copyright (c) 2015 Olivier THIERRY. All rights reserved.
//

import Foundation

public func incoming() -> Promise {
  return Promise()
}

public func incoming(closure: Promise -> Void) -> Promise {
  let promise = Promise()
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
    closure(promise)
  }
  return promise
}
