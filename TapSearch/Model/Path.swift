//
//  PathLocations.swift
//  TapSearch
//
//

import Foundation

public struct Path: Equatable {
  var locations = PathLocations()
  var start: TileLocation
  var end: TileLocation
  
  public static func ==(lhs: Path, rhs: Path) -> Bool {
    return (lhs.locations == rhs.locations)
  }
  /**
   Computed variable of path orientation in any of the 8 cardinal directions. Not explicitly necessary
   for this iteration of the application.
   */
  var orientation: PathOrientation {
    
    guard start != end else {
      return .singlet
    }
    let deltaX: Int = start.x - end.x
    let deltaY: Int = start.y - end.y
    
    switch (deltaX, deltaY) {
    case (0, _):           //Vertical   / Single Tile
      if deltaY > 0 {
        return .south
      } else {
        return .north
      }
    case (_, 0):           //Horizontal / Single Tile
      if deltaX > 0 {
        return .west
      } else {
        return .east
      }
    case (abs(deltaX), abs(deltaX)): //Diagonal   / Single Tile
      if deltaX > 0 {
        if deltaY > 0 {
          return .southWest
        } else {
          return .northWest
        }
      } else {
        if deltaY > 0 {
          return .southEast
        } else {
          return .northEast
        }
      }
    default:               //invalid path
      return .invalid
    }
  }
}

enum PathOrientation {
  case north
  case northEast
  case east
  case southEast
  case south
  case southWest
  case west
  case northWest
  case singlet
  case invalid
}

