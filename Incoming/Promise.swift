
import Foundation

protocol Invokable {
  func invoke(with: Any?) -> Any?
  func isTypeError(with: Any?) -> Bool
  func expectedType() -> Any
}

public class Then<A, B> : Invokable {
  public typealias Fn = A -> B
  
  var f: Fn
  
  lazy var g : (Void -> B)? = {
    let wrapped : Any = self.f
    return wrapped as? Void -> B
    }()
  
  public required init(f: Fn) {
    self.f = f
  }
  
  // - Invokable
  func invoke(with: Any?) -> Any? {
    if let g = g {
      return g()
    } else if let with = with as? A {
      return f(with)
    } else {
      return nil
    }
  }
  
  func isTypeError(with: Any?) -> Bool {
    return !(g != nil || with is A)
  }
  
  func expectedType() -> Any {
    return A.self
  }
}

public class Catch : Invokable {
  public typealias Fn = NSError? -> Void
  
  var f: Fn
  
  public required init(f: Fn) {
    self.f = f
  }
  
  // - Invokable
  func invoke(with: Any?) -> Any? {
    return f(with as? NSError)
  }
  
  func isTypeError(with: Any?) -> Bool {
    return !(with is NSError)
  }
  
  func expectedType() -> Any {
    return NSError.self
  }
}

//public enum Future<A> {
//  case Success(A)
//  case Failure(NSError)
//  
//  var isError: Bool {
//    switch self {
//    case .Success(_):
//      return false
//    case .Failure(_):
//      return true
//    }
//  }
//  
//  var value: Any? {
//    switch self {
//    case .Success(let value):
//      return value
//    case .Failure(let error):
//      return error
//    }
//  }
//}

public class Promise {
  
  public enum State : Int {
    case Pending
    case Resolved
    case Rejected
  }
  
  private var fn: [Invokable] = []
  
  public private(set) var state : State = .Pending
  public private(set) var value: Any?
  public private(set) var error: NSError?
  
  // MARK: - Then/Catch flow
  // closure takes no parameter and does not return
  public func then(onFulfilled: Then<Void, Void>.Fn) -> Promise {
    append(Then(f: onFulfilled))
    return self
  }
  
  
  // closure takes no parameter and returns a specified type
  public func then<A>(onFulfilled: Then<Void, A>.Fn) -> Promise {
    append(Then(f: onFulfilled))
    return self
  }
  
  // closure takes parameter with specified type and returns a specified type
  public func then<A, B>(onFulfilled: Then<A, B>.Fn) -> Promise {
    append(Then(f: onFulfilled))
    return self
  }
  
  // closure takes parameter with specified type and does not return
  public func then<A>(onFulfilled: Then<A, Void>.Fn) -> Promise {
    append(Then(f: onFulfilled))
    return self
  }
  
  public func fail(onRejected: Catch.Fn) -> Promise {
    append(Catch(f: onRejected))
    return self
  }
  
  // MARK: - Resolve/Reject
  
  public func resolve() {
    resolve(nil)
  }
  
  public func resolve(value: Any?) {
    self.value = value
    dispatch_async(dispatch_get_main_queue(), resolveAll)
  }

  public func reject() {
    reject(nil)
  }
  
  public  func reject(error: NSError?) {
    self.error = error
    dispatch_async(dispatch_get_main_queue(), rejectAll)
  }
  
  // MARK: - Private
  
  private func append(f: Invokable) {
    fn.append(f)
    
    switch state {
    case .Rejected:
      rejectAll()
    case .Resolved:
      resolveAll()
    default: ()
    }
  }
  
  private func dequeue() -> Invokable? {
    return fn.isEmpty ? nil : fn.removeAtIndex(0)
  }
  
  private func rejectAll() {
    if let f = dequeue() {
      if f is Catch {
        f.invoke(error)
      }
      rejectAll()
    } else {
      state = .Rejected
    }
  }
  
  private func resolveTypeError(expectedType: Any, resolvedType: Any) {
    reject(NSError(
      domain: "Promise",
      code: 42,
      userInfo: ["Message": "Type error: expected \(expectedType) but got \(resolvedType)"]))
  }
  
  private func handleResolvedPromise(promise: Promise) {
    if (self === promise) {
      // Promise/A+ specs:
      // returned promise must not equal self
      self.reject(NSError(
        domain: "Promise",
        code: 42,
        userInfo: ["Message": "SameType error"]))
    } else {
      promise
        .then { _ in
          self.resolve(promise.value) }
        .fail { _ in
          self.reject(promise.error) }
    }
  }
  
  // Adopt new state
  private func handleResolvedValue(value: Any?) {
    resolve(value)
  }
  
  // No return value, continue with pevious state
  private func handleResolvedVoid() {
    resolve(value)
  }
  
  private func resolveAll() {
    if let f = dequeue() {
      if f is Catch {
        return resolveAll()
      } else if f.isTypeError(value) {
        return resolveTypeError(f.expectedType(), resolvedType: value.self)
      } else {
        let retVal = f.invoke(value)
        if let promise = retVal as? Promise {
          handleResolvedPromise(promise)
        } else if retVal is Void {
          handleResolvedVoid()
        } else {
          handleResolvedValue(retVal)
        }
      }
    } else {
      state = .Resolved
    }
  }
}