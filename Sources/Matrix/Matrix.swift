//
//  Matrix.swift
//
//  Created by Andrew Cowley on 15/12/2021.
//
import Foundation

struct Matrix<T: RangeReplaceableCollection & Equatable>: Equatable {
   static func == (lhs: Matrix, rhs: Matrix) -> Bool {
      lhs.wrapped == rhs.wrapped && lhs.rowLength == rhs.rowLength
   }

   private var wrapped: [T]
   private var rowLength: Int
   public var row: Row<T>
   public var column: Column<T>

   // Init with single array of type T, e.g. String
   init(_ wrapped: [T], rowLength: Int ) {
      assert(Double(wrapped.count/rowLength) == Double(wrapped.count) / Double(rowLength), "Array not divisible by rowlength")
      self.wrapped = wrapped
      self.rowLength = rowLength
      self.row = Row(wrapped: wrapped, rowLength: rowLength)
      self.column = Column(wrapped: wrapped, rowLength: rowLength)
   }

   internal class Column<T: RangeReplaceableCollection & Equatable> {
      private var wrapped: [T]
      private var rowLength: Int
      private var numRows: Int { wrapped.count / rowLength }
      static func == (lhs: Column, rhs: Column) -> Bool {
         lhs.wrapped == rhs.wrapped && lhs.rowLength == rhs.rowLength
      }
      init(wrapped: [T], rowLength: Int ) {
         self.wrapped = wrapped; self.rowLength = rowLength
      }
      subscript(col: Int) -> T {
         get {
            var tmp = T()
            for i in 0..<numRows {
               let index = wrapped.index(wrapped.startIndex, offsetBy: i*rowLength + col)
               tmp = tmp + T(wrapped[index])
            }
            return tmp
         }
      }
   }
   internal class Row<T: RangeReplaceableCollection & Equatable> {
      private var wrapped: [T]
      private var rowLength: Int
      static func == (lhs: Row, rhs: Row) -> Bool {
         lhs.wrapped == rhs.wrapped && lhs.rowLength == rhs.rowLength
      }
      init(wrapped: [T], rowLength: Int ) {
         self.wrapped = wrapped; self.rowLength = rowLength
      }
      subscript(row: Int) -> T {
         get {
            let indexStart = wrapped.index(wrapped.startIndex, offsetBy: row*rowLength)
            var tmp = T()
            for i in 0..<rowLength {
               let index = wrapped.index(indexStart, offsetBy: i)
               tmp = tmp + T(wrapped[index])
            }
            return tmp
         }
      }
   }
   func indexIsValid(row: Int, column: Int) -> Bool {
      return row * column + column < wrapped.count
   }
   subscript(row: Int, column: Int) -> T {
      get {
         assert(indexIsValid(row: row, column: column), "Index out of range")
         return wrapped[(row * rowLength) + column]
      }
      set {
         assert(indexIsValid(row: row, column: column), "Index out of range")
         wrapped[(row * rowLength) + column] = newValue
      }
   }
}
