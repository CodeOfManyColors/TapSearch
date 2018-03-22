//
//  PuzzleStore.swift
//  TapSearch
//
//

import Foundation

class PuzzleStore: APIClient {
  
  private var currentPuzzle: WordPuzzle?
  private var unseenPuzzles = [WordPuzzle]()
  private var completedPuzzles = [WordPuzzle]()
  public var unseenPuzzleCount: Int {
    return unseenPuzzles.count
  }
  
  //MARK: API Methods
  //Each APIClient conforming object needs to be initialized with a URL Session
  let session: URLSession
  
  init(configuration: URLSessionConfiguration) {
    self.session = URLSession(configuration: configuration)
  }
  
  convenience init() {
    self.init(configuration: .default)
  }
  
  /**
   Attempts to retrieve puzzles from the API endpoint
   - Parameter puzzleLocation: An enumeration of endpoint locations available to the client
   - Returns: completion: Result object that indicates a binary success or failure. Success is an array or word puzzles while
              failure returns an APIError object
  */
  func retrievePuzzles(from puzzleLocation: PuzzleLocation, completion: @escaping (Result<[WordPuzzle], APIError>) -> Void) {
    
    let endpoint = puzzleLocation
    let request = endpoint.request
    
    fetchArray(with: request, decode: { json -> WordPuzzle? in
      guard let wordpuzzle = json as? WordPuzzle else { return  nil }
      return wordpuzzle
    }, completion: completion)
  }
  
  
  /**
   Demo function for parsing .json file instead of interacting with api
   */
  func retrievePuzzlesOffline() -> [WordPuzzle] {
    guard let path = Bundle.main.path(forResource: "sample", ofType: "json") else {
      print("The path could not be created.")
      return []
    }
    
    var decodedObjects = [WordPuzzle]()

    do {
      let content = try String(contentsOfFile:path, encoding: .utf8)
      var stringJSONObjects = [String]()
      
      content.enumerateLines { stringJSONObject, _ in
        stringJSONObjects.append(stringJSONObject)
      }
      
      for JSONobject in stringJSONObjects {
        do {
          //Attempts to decode data based on the input decodable struct
          let jsonDecoder = JSONDecoder()
          let genericModel = try jsonDecoder.decode(WordPuzzle.self, from: JSONobject.data(using: .utf8)!)
            decodedObjects.append(genericModel)
        } catch {
          print("Could not decode object")
        }
      }
    } catch {
      print("error:\(error)")
    }
    
    return decodedObjects
  }
  
  //MARK: Puzzle getters and setters
  func add(puzzle: WordPuzzle) {
    self.unseenPuzzles.append(puzzle)
  }
  
  /**
   This function:
      - Grabs the next puzzle in the queue,
      - Marks the current puzzle as completed
      - Installs the next puzzle as current puzzle
      - In the future it could also prompt the API to download more puzzles.
   */
  func getNextPuzzle() -> WordPuzzle? {
    guard let nextPuzzle = unseenPuzzles.popLast() else {
      // Ask for next page of puzzles from api
      return nil
    }
    if unseenPuzzleCount < 2 {
      // Ask for next page of puzzles from api
    }
    if let completedPuzzle = self.currentPuzzle {
      self.completedPuzzles.append(completedPuzzle)
    }
    self.currentPuzzle = nextPuzzle
    return currentPuzzle
  }
  
  func getCurrentPuzzle() -> WordPuzzle? {
    guard currentPuzzle != nil else {return nil}
    return currentPuzzle!
  }
  
  func updateCurrentPuzzle(struct mutatedPuzzleCopy: WordPuzzle) {
    self.currentPuzzle = mutatedPuzzleCopy
  }
}

enum APIError: Error {
  case invalidURL
  case responseDataNil
  case stringDecodingError
  case missingRequiredValues
  case languageNotSupported
  case gridDimensionsOutOfBounds
  case invalidCharacterInGrid
  case invalidSolutionPath
  case invalidCharacterInSolutionPath
  case dataTaskError
  
  var localizedDescription: String {
    switch self {
    case .invalidURL:
      return "The url base/path strings provided form an invalid URL"
    case .responseDataNil:
      return "There was no response to the URL request"
    case .stringDecodingError:
      return "There response data could note be parsed into lines, check the integrity of that data at the given URL"
    case .missingRequiredValues:
      return "Decoded data is missing one, or all of the required values for a valid JSON object"
    case .languageNotSupported:
      return "The language supplied in this JSON file is not supported by this version of the application"
    case .gridDimensionsOutOfBounds:
      return "The grid is either too large or too small to be displayed by this application"
    case .invalidCharacterInGrid:
      return "The word grid contains a character which is not parsable is Swift"
    case .invalidSolutionPath:
      return "Solution path should contain an even number of digits"
    case .invalidCharacterInSolutionPath:
      return "Ensure that all values in the solution path are Ints"
    case .dataTaskError:
      return "URLSession data task failed"
    }
  }
}
