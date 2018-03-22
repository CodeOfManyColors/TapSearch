//
//  Endpoint.swift
//  TapSearch
//
//

import Foundation


protocol Endpoint {
  var base: String { get }
  var path: String { get }
}

extension Endpoint {
  
  var urlComponents: URLComponents {
    var components = URLComponents(string: base)!
    components.path = path
    return components
  }
  
  var request: URLRequest {
    let url = urlComponents.url!
    return URLRequest(url: url)
  }
}

enum PuzzleLocation {
  case findChallenges
}

extension PuzzleLocation: Endpoint {
  
  var base: String {
    return "https://some.base.address.com"
  }
  
  var path: String {
    switch self {
    case .findChallenges:
      return "/path/to/data/abc123"
    }
    //Add in addition paths
  }
  
}
