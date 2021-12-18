//
//  Matrix.swift
//
//  Created by Andrew Cowley on 15/12/2021.
//
import SwiftUI
import Combine

class Wrapped<T: Equatable & RangeReplaceableCollection>: Equatable, ObservableObject, DynamicProperty {
   @Published var values: [T]
   let rowLength: Int
   var colLength: Int { values.count / rowLength }
   init(_ values: [T], rowLength: Int) {
      self.values = values
      self.rowLength = rowLength
   }
   static func == (lhs: Wrapped<T>, rhs: Wrapped<T>) -> Bool {
      lhs.values == rhs.values && lhs.rowLength == rhs.rowLength
   }
}

class Column<T: Equatable & RangeReplaceableCollection> {
   var wrapped: Wrapped<T>
   init(wrapped: Wrapped<T>) { self.wrapped = wrapped }

   subscript(col: Int) -> [T] {
      get {
         var tmp = [T()]
         for i in 0..<wrapped.colLength {
            let index = wrapped.values.index(wrapped.values.startIndex, offsetBy: i*wrapped.rowLength + col)
            tmp.append(T(wrapped.values[index]))
         }
         return tmp
      }
      set {
         assert(newValue.count == wrapped.colLength, "Invalid column length of newValue(\(newValue.count))")
         print("Column setter.  collength: \(wrapped.colLength)")
         for i in 0..<wrapped.colLength {
            let index = wrapped.values.index(wrapped.values.startIndex, offsetBy: i*wrapped.rowLength + col)
            wrapped.values[index] = newValue[i]
         }
      }
   }
}

class Row<T: Equatable & RangeReplaceableCollection> {
   var wrapped: Wrapped<T>
   init(wrapped: Wrapped<T>) { self.wrapped = wrapped }

   subscript(row: Int) -> [T] {
      get {
         let indexStart = wrapped.values.index(wrapped.values.startIndex, offsetBy: row*wrapped.rowLength)
         var tmp = [T()]
         for i in 0..<wrapped.rowLength {
            tmp.append( T(wrapped.values[wrapped.values.index(indexStart, offsetBy: i)]))
         }
         return tmp
      }
      set {
         assert(newValue.count == wrapped.rowLength,"Invalid row length of newValue")
         print("Row setter.  rowlength: \(wrapped.rowLength)")
         let indexStart = wrapped.values.index(wrapped.values.startIndex, offsetBy: row * wrapped.rowLength)
         let indexEnd = wrapped.values.index(wrapped.values.startIndex, offsetBy: ((row+1)*wrapped.rowLength-1))
         wrapped.values.replaceSubrange(indexStart...indexEnd, with: newValue)
      }
   }
}

public final class Matrix<T: Equatable & RangeReplaceableCollection> : DynamicProperty, ObservableObject {
   var wrapped: Wrapped<T> { willSet { objectWillChange.send() } }
   private var cancellable: AnyCancellable?
   var column: Column<T>
   var row: Row<T>

   public init(values: [T], rowLength: Int) {
      assert(Double(values.count/rowLength) == Double(values.count) / Double(rowLength), "Array not divisible by rowlength")
      let w = Wrapped(values, rowLength: rowLength)
      row = Row(wrapped: w)
      column = Column(wrapped: w)
      wrapped = w
      cancellable = w.$values.sink { _ in self.objectWillChange.send() }
   }
   public init() {
      let w = Wrapped([T()], rowLength: 0)
      row = Row(wrapped: w)
      column = Column(wrapped: w)
      wrapped = w
   }
   func printme() {
      print("From the Matrix")
      var tmp=""
      for row in 0..<wrapped.colLength {
         for col in 0..<wrapped.rowLength {
            tmp = tmp + "\(wrapped.values[wrapped.values.index(wrapped.values.startIndex, offsetBy: row*wrapped.rowLength+col)])"
         }
         print(tmp)
         tmp=""
      }
   }

   func indexIsValid(row: Int, column: Int) -> Bool {
      return row * wrapped.rowLength + column < wrapped.values.count
   }

   subscript(row: Int, column: Int) -> T {
      get {
         assert(indexIsValid(row: row, column: column), "Index out of range")
         return wrapped.values[row*wrapped.rowLength + column]
      }
      set {
         assert(indexIsValid(row: row, column: column), "Index out of range")
         wrapped.values[row*wrapped.rowLength + column] = newValue
      }
   }
}

//------------------------------
extension Matrix: RangeReplaceableCollection {

   public typealias Index = Array<T>.Index
   public typealias Element = T



   // The upper and lower bounds of the collection, used in iterations
   public var startIndex: Index { return wrapped.values.startIndex }
   public var endIndex: Index { return wrapped.values.endIndex }

   // Required subscripts
   public subscript(position: Index) -> Element {
      get { return wrapped.values[position]}
      set { wrapped.values[position] = newValue }
   }
   public subscript(bounds: Range<Index>) -> SubSequence {
      get { return wrapped.values[bounds] }
      set { wrapped.values.replaceSubrange(bounds, with: newValue)}
   }

   // Required Method that returns the next index when iterating
   public func index(after i: Index) -> Index {
      return wrapped.values.index(after: i)
   }

   public typealias SubSequence = ArraySlice<T>
}

extension Matrix: Equatable {
   public static func == (lhs: Matrix, rhs: Matrix) -> Bool {
      lhs.wrapped == rhs.wrapped
   }
}
