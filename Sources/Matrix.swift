//
//  Matrix.swift
//
//  Created by Andrew Cowley on 15/12/2021.
//
import SwiftUI
import Combine

public final class Matrix<T>: Identifiable, ObservableObject {

   public let id = UUID().uuidString
   public var row: Row
   public var column: Column

   private var wrapped: Wrapped { willSet { objectWillChange.send() } }
   private var cancellable: AnyCancellable?

   public init(_ values: [T], rowLength: Int) {
      assert(Double(values.count/rowLength) == Double(values.count) / Double(rowLength), "Array not divisible by rowlength")
      let w = Wrapped(values, rowLength: rowLength)
      row = Row(wrapped: w)
      column = Column(wrapped: w)
      wrapped = w
      cancellable = w.$values.sink { [weak self] _ in self?.objectWillChange.send() }
   }
}

extension Matrix {
   /// store the 1d array values for the matrix
   class Wrapped: ObservableObject {
      @Published fileprivate var values: [T]
      public let rowLength: Int
      public var colLength: Int { values.count / rowLength }
      init(_ values: [T], rowLength: Int) {
         self.values = values
         self.rowLength = rowLength
      }
   }
   public var rowLength: Int { wrapped.rowLength }
   public var colLength: Int { wrapped.colLength }
   public var values: [T] { wrapped.values }
}

extension Matrix {
   public class Column {
      private var wrapped: Wrapped
      fileprivate init(wrapped: Wrapped) { self.wrapped = wrapped }

      public subscript(col: Int) -> [T] {
         get {
            var column: [T] = []
            for i in 0..<wrapped.colLength {
               let index = wrapped.values.index(wrapped.values.startIndex, offsetBy: i*wrapped.rowLength + col)
               column.append(wrapped.values[index])
            }
            return column
         }
         set {
            assert(newValue.count == wrapped.colLength, "Invalid column length of newValue(\(newValue.count))")
            for i in 0..<wrapped.colLength {
               let index = wrapped.values.index(wrapped.values.startIndex, offsetBy: i*wrapped.rowLength + col)
               wrapped.values[index] = newValue[i]
            }
         }
      }
   }
}

extension Matrix {
   public class Row {
      private var wrapped: Wrapped
      fileprivate init(wrapped: Wrapped) { self.wrapped = wrapped }
      public subscript(row: Int) -> [T] {
         get {
            let indexStart = wrapped.values.index(wrapped.values.startIndex, offsetBy: row*wrapped.rowLength)
            var rowArray: [T] = []
            for i in 0..<wrapped.rowLength {
               rowArray.append( wrapped.values[wrapped.values.index(indexStart, offsetBy: i)])
            }
            return rowArray
         }
         set {
            assert(newValue.count == wrapped.rowLength,"Invalid row length of newValue")
            let indexStart = wrapped.values.index(wrapped.values.startIndex, offsetBy: row * wrapped.rowLength)
            let indexEnd = wrapped.values.index(wrapped.values.startIndex, offsetBy: ((row+1)*wrapped.rowLength-1))
            wrapped.values.replaceSubrange(indexStart...indexEnd, with: newValue)
         }
      }
   }
}

extension Array {
   public func asString() -> String {
      self.reduce("") {i,j in return "\(i)\(j) "  }
   }
}
extension Matrix {
   public func printme() {
      print("From the Matrix")
      for row in 0..<wrapped.colLength {
         print(self.row[row].asString())
      }
   }
}

// MARK - Matrix subscript [row][col]
extension Matrix {
   private func indexIsValid(row: Int, column: Int) -> Bool {
      return row * wrapped.rowLength + column < wrapped.values.count
   }

   public subscript(row: Int, column: Int) -> T {
      get {
         assert(indexIsValid(row: row, column: column), "Index out of range")
         let index = wrapped.values.index(wrapped.values.startIndex, offsetBy: row*wrapped.rowLength + column)
         return wrapped.values[index]
      }
      set {
         assert(indexIsValid(row: row, column: column), "Index out of range")
         let index = wrapped.values.index(wrapped.values.startIndex, offsetBy: row*wrapped.rowLength + column)
         wrapped.values[index] = newValue
      }
   }
}

//------------------------------

extension Matrix: RangeReplaceableCollection {
   public typealias Index = Array<T>.Index
   public typealias Element = T
   public typealias SubSequence = ArraySlice<T>

   // Collection required: upper and lower bounds of the collection, used in iterations
   public var startIndex: Index { return wrapped.values.startIndex }
   public var endIndex: Index { return wrapped.values.endIndex }

   // Collection required: Method that returns the next index when iterating
   public func index(after i: Index) -> Index {
      return wrapped.values.index(after: i)
   }

   public func index(before i: Index) -> Index {
      return wrapped.values.index(before: i)
   }

   // Required subscripts
   public subscript(position: Index) -> Element {
      get { return wrapped.values[position]}
      set { wrapped.values[position] = newValue }
   }
   public subscript(bounds: Range<Index>) -> SubSequence {
      get { return wrapped.values[bounds] }
      set { wrapped.values.replaceSubrange(bounds, with: newValue)}
   }

   // Empty initialiser
   public convenience init() {
      self.init([], rowLength: 0)
   }
}

extension Matrix: Equatable where T: Equatable {
   public static func == (lhs: Matrix, rhs: Matrix) -> Bool {
      lhs.wrapped.values == rhs.wrapped.values && lhs.wrapped.rowLength == rhs.wrapped.rowLength
   }
}

extension Matrix: Hashable where T: Hashable {
   public func hash(into hasher: inout Hasher) {
      for value in self.wrapped.values {
         hasher.combine(value)
      }
      hasher.combine(self.wrapped.rowLength)
   }
}
