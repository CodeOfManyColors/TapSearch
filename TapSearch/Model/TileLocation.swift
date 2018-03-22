//
//  TileLocation.swift
//  TapSearch
//
//

import Foundation


/**
Struct used to keep track of integer addresses of tiles. Important for this object to be
hashable for Set inclusion
*/

typealias PathLocations = Set<TileLocation>

struct TileLocation: Equatable, Hashable {
  
  let x: Int
  let y: Int
  
  var hashValue: Int {
    return x.hashValue ^ y.hashValue
  }

  static func ==(lhs: TileLocation, rhs: TileLocation) -> Bool {
    return (lhs.x == rhs.x) && (lhs.y == rhs.y)
  }
}
