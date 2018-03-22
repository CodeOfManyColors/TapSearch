//
//  GridCheckingTests.swift
//  TapSearchTests
//
//

import XCTest

class GridCheckingTests: XCTestCase {
  var wordGridViewController  = WordPuzzleViewController()
  var validJSON: String!
  var jsonMissingSourceLanguage: String!
  var jsonMissingDestinationLanguage: String!
  var jsonWithInvalidCharacters: String!
  var jsonMissingCharacterGrid: String!
  var jsonMissingAnswerPath: String!
  var JSONMissingFields: [String]!
  
  override func setUp() {
    super.setUp()
    initializeJsonFiles()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  
  func test_ParsesValidJSON() {
    let jsonDecoder = JSONDecoder()
    var validWordPuzzle : WordPuzzle?
    do {
      validWordPuzzle = try jsonDecoder.decode(WordPuzzle.self, from: validJSON.data(using: .utf8)!)
    } catch {
      
    }
    
    XCTAssertEqual(validWordPuzzle!.sourceLanguage, "en")
    XCTAssertEqual(validWordPuzzle!.targetLanguage, "es")
    XCTAssertEqual(validWordPuzzle!.word, "bread")
    XCTAssertEqual(validWordPuzzle!.wordLocations.count, 1)
    XCTAssertEqual(validWordPuzzle!.wordLocations.count, 1)
  }
  
  func test_RejectsJSON_MissingRequiredField() {
    let jsonDecoder = JSONDecoder()
    for jsonSample in JSONMissingFields {
      XCTAssertThrowsError(try jsonDecoder.decode(WordPuzzle.self, from: jsonSample.data(using: .utf8)!)) { error in
        XCTAssertEqual(error as? APIError, APIError.missingRequiredValues)
      }
    }
  }
  
  func test_ParsesValidJSON_CorrectCharacterGrid(){
    let jsonDecoder = JSONDecoder()
    var validWordPuzzle : WordPuzzle?
    do {
      validWordPuzzle = try jsonDecoder.decode(WordPuzzle.self, from: validJSON.data(using: .utf8)!)
      let column0 = [Character("Ü"), Character("Á"), Character("P"), Character("A"), Character("N")]
      let column1 = [Character("K"), Character("A"), Character("K"), Character("M"), Character("L")]
      let column2 = [Character("A"), Character("X"), Character("Q"), Character("E"), Character("H")]
      let column3 = [Character("P"), Character("S"), Character("A"), Character("J"), Character("Í")]
      let column4 = [Character("Á"), Character("Q"), Character("L"), Character("J"), Character("L")]
      let badColumn = [Character("Á"), Character("q"), Character("L"), Character("J"), Character("L")]
      
      
      let characterGrid = [column0, column1, column2, column3, column4]
      let badCharacterGrid = [column0, column1, column2, column3, badColumn]

      XCTAssert(validWordPuzzle!.characterGrid == characterGrid)
      XCTAssert(validWordPuzzle!.characterGrid != badCharacterGrid)

      
      
      
    } catch {
      XCTFail()
    }
  }
  func test_RejectsJSON_invalidCharacterInGrid() {
    
    let jsonDecoder = JSONDecoder()
    XCTAssertThrowsError(try jsonDecoder.decode(WordPuzzle.self, from: jsonWithInvalidCharacters.data(using: .utf8)!)) { error in
      XCTAssertEqual(error as? APIError, APIError.invalidCharacterInGrid)
    }
  }
  
  func test_ChecksAnswer_correctAnswer() {
    
    let jsonDecoder = JSONDecoder()
    let panPuzzle : WordPuzzle?
    let touchBegin = TileLocation(x: 0, y: 2)
    let middleTile = TileLocation(x: 0, y: 3)
    let touchEnd = TileLocation(x: 0, y: 4)
    var pathLocations = PathLocations()
    pathLocations.insert(touchBegin)
    pathLocations.insert(middleTile)
    pathLocations.insert(touchEnd)
    let touchPath = Path(locations: pathLocations, start: touchBegin, end: touchEnd)
    
    
    do {
      panPuzzle = try jsonDecoder.decode(WordPuzzle.self, from: validJSON.data(using: .utf8)!)
      let solutionNumber = wordGridViewController.checkAnswer(currentPuzzle: panPuzzle!, path: touchPath)
      XCTAssert(solutionNumber == 0)
    } catch {
      XCTFail()
    }
    
  }
  
  func test_ChecksAnswer_rejectsIncorrectAnswers() {
    var offsetCases = [(Int, Int)]()
    
    //Checking all the possible cases around the starting tile
    for i in -1...1 {
      for j in -1...1 {
        //if (i, j) != (0,1) { //Don't add the valid path!
          offsetCases.append((i,j))
        //}
      }
    }
    for offset in offsetCases {
      var tileLocations = [TileLocation]()
      let firstTile = TileLocation(x: 0, y: 2)
      let secondTile = TileLocation(x: 0 +  offset.0, y: 2 + offset.1)
      let thirdTile = TileLocation(x: 0 + 2 * offset.0, y: 2 + 2 * offset.1)
      let fourthTile = TileLocation(x: 0 + 3 * offset.0, y: 2 + 3 * offset.1)

      var pathLocations = PathLocations()
      pathLocations.insert(firstTile)
      pathLocations.insert(secondTile)
      let twoTilePath = Path(locations: pathLocations, start: firstTile, end: secondTile)

      pathLocations.insert(thirdTile)
      let threeTilePath = Path(locations: pathLocations, start: firstTile, end: thirdTile)

      pathLocations.insert(fourthTile)
      let fourTilePath = Path(locations: pathLocations, start: firstTile, end: fourthTile)
      //check 3 tiles
      
      for path in [twoTilePath, threeTilePath, fourTilePath] {
        do {
          let jsonDecoder = JSONDecoder()
          var panPuzzle = try jsonDecoder.decode(WordPuzzle.self, from: validJSON.data(using: .utf8)!)
          
          let solutionNumber = wordGridViewController.checkAnswer(currentPuzzle: panPuzzle, path: path)
          if offset == (0,1),
             path == threeTilePath {
            //Skip this one, it's the correct answer
            print("Skipping answer")
          } else {
            XCTAssert(solutionNumber == nil)
          }
        } catch {
          XCTFail()
        }
      }
    }
  }
  
  func initializeJsonFiles() {
    
    
    validJSON = "{\"source_language\": \"en\", \"word\": \"bread\", \"character_grid\": [[\"\u{00fc}\", \"\u{00e1}\", \"p\", \"a\", \"n\"], [\"k\", \"a\", \"k\", \"m\", \"l\"], [\"a\", \"x\", \"q\", \"e\", \"h\"], [\"p\", \"s\", \"a\", \"j\", \"\u{00ed}\"], [\"\u{00e1}\", \"q\", \"l\", \"j\", \"l\"]], \"word_locations\": {\"2,0,3,0,4,0\": \"pan\"}, \"target_language\": \"es\"}"
    
    jsonMissingSourceLanguage = "{\"word\": \"bread\", \"character_grid\": [[\"\u{00fc}\", \"\u{00e1}\", \"p\", \"a\", \"n\"], [\"k\", \"a\", \"k\", \"m\", \"l\"], [\"a\", \"x\", \"q\", \"e\", \"h\"], [\"p\", \"s\", \"a\", \"j\", \"\u{00ed}\"], [\"\u{00e1}\", \"q\", \"l\", \"j\", \"l\"]], \"word_locations\": {\"2,0,3,0,4,0\": \"pan\"}, \"target_language\": \"es\"}"
    
    jsonMissingDestinationLanguage = "{\"source_language\": \"en\", \"word\": \"bread\", \"character_grid\": [[\"\u{00fc}\", \"\u{00e1}\", \"p\", \"a\", \"n\"], [\"k\", \"a\", \"k\", \"m\", \"l\"], [\"a\", \"x\", \"q\", \"e\", \"h\"], [\"p\", \"s\", \"a\", \"j\", \"\u{00ed}\"], [\"\u{00e1}\", \"q\", \"l\", \"j\", \"l\"]], \"word_locations\": {\"2,0,3,0,4,0\": \"pan\"}}"
    
    jsonMissingCharacterGrid = "{\"source_language\": \"en\", \"word\": \"bread\", \"word_locations\": {\"2,0,3,0,4,0\": \"pan\"}, \"target_language\": \"es\"}"
    
    jsonMissingAnswerPath = "{\"source_language\": \"en\", \"word\": \"bread\", \"character_grid\": [[\"\u{00fc}\", \"\u{00e1}\", \"p\", \"a\", \"n\"], [\"k\", \"a\", \"k\", \"m\", \"l\"], [\"a\", \"x\", \"q\", \"e\", \"h\"], [\"p\", \"s\", \"a\", \"j\", \"\u{00ed}\"], [\"\u{00e1}\", \"q\", \"l\", \"j\", \"l\"]], \"target_language\": \"es\"}"
    
    
    //Sentence in character grid
    jsonWithInvalidCharacters = "{\"source_language\": \"en\", \"word\": \"bread\", \"character_grid\": [[\"\u{00fc}\", \"I_AM_AN_INVALID_CHARACTER\", \"p\", \"a\", \"n\"], [\"k\", \"a\", \"k\", \"m\", \"l\"], [\"a\", \"x\", \"q\", \"e\", \"h\"], [\"p\", \"s\", \"a\", \"j\", \"\u{00ed}\"], [\"\u{00e1}\", \"q\", \"l\", \"j\", \"l\"]], \"word_locations\": {\"2,0,3,0,4,0\": \"pan\"}, \"target_language\": \"es\"}"
    
    
    
    JSONMissingFields = [jsonMissingSourceLanguage, jsonMissingDestinationLanguage, jsonMissingCharacterGrid, jsonMissingAnswerPath ]
    //var validCharacterGrid = [[Character]]?
  }
}
