//
//  JSONObjects.swift
//  TapSearch
//
//
import Foundation

struct WordPuzzle : Codable {
  let word : String
  let stringGrid : [[String]]
  let wordLocations : [String: String]
  let sourceLanguage : String
  let targetLanguage : String
  let enumSource : AvailableLanguage
  let enumTarget : AvailableLanguage
  var answerKey = AnswerKey()
  var completedAnswers = AnswerKey()
  var characterGrid = [[Character]]()
  
  enum CodingKeys: String, CodingKey {
    
    case sourceLanguage = "source_language"
    case word = "word"
    case stringGrid = "character_grid"
    case wordLocations = "word_locations"
    case targetLanguage = "target_language"
  }
  
  init(from decoder: Decoder) throws {
    
    //Ensure all major keys are present, else throw decoding error
    let values = try decoder.container(keyedBy: CodingKeys.self)
    guard let word = try values.decodeIfPresent(String.self, forKey: .word),
          let stringGrid = try values.decodeIfPresent([[String]].self, forKey: .stringGrid),
          let wordLocations = try values.decodeIfPresent([String: String].self, forKey: .wordLocations),
          let targetLanguage = try values.decodeIfPresent(String.self, forKey: .targetLanguage),
          let sourceLanguage = try values.decodeIfPresent(String.self, forKey: .sourceLanguage) else {
       
            throw APIError.missingRequiredValues
    }
    
    //Ensure that the languages in the puzzle are supported by the app
    guard let enumSourceLanguage = AvailableLanguage(rawValue: sourceLanguage),
          let enumTargetLanguage = AvailableLanguage(rawValue: targetLanguage) else {
            throw APIError.languageNotSupported
    }
    
    self.word = word
    self.stringGrid = stringGrid
    self.wordLocations = wordLocations
    self.sourceLanguage = enumSourceLanguage.rawValue
    self.targetLanguage = enumTargetLanguage.rawValue
    self.enumSource = enumSourceLanguage
    self.enumTarget = enumTargetLanguage
    
    //Parse the answer key
    for key in wordLocations.keys {
      if let translationAnswer = wordLocations[key] {
        do {
          let correctPath = try self.parseWordLocations(string: key)
          self.answerKey.append((translationAnswer, correctPath))
        } catch {
          throw APIError.invalidSolutionPath
        }
      }
    }
    
    //Validate the puzzle grid
    do {
      if let convertedGrid = try validate(stringMap: stringGrid) {
        self.characterGrid = convertedGrid
      }
    } catch APIError.gridDimensionsOutOfBounds {
      throw APIError.gridDimensionsOutOfBounds
    } catch APIError.invalidCharacterInGrid {
      throw APIError.invalidCharacterInGrid
    }
  }
  
  /**
   Ensures that the word locations provided by the api are valid pairs of integers
  */
  func parseWordLocations(string: String) throws  -> PathLocations {
    
    var locations = Set<TileLocation>()
    var digits = string.split(separator: Character(","))
    
    //Ensure valid number of coordinates, w/ arbitrary max to allow for API changes
    guard digits.count % 2 == 0,
          digits.count <= 100,
          digits.count >= 2    else {
      throw APIError.invalidSolutionPath
    }
    
    while digits.count >= 2 {
      if digits.indices.contains(0),
         digits.indices.contains(1),
         let row = Int(digits[0]),
         let column = Int(digits[1]) {

        locations.insert(TileLocation(x: column, y: row))
        digits.removeFirst()
        digits.removeFirst()
      } else {
        throw APIError.invalidCharacterInSolutionPath
      }
    }
    return locations
  }
  
  /**
   Tests whether the character string map provided by the API can successfully be
   parsed into characters recognized by swift. Also enforces grid sizes to ensure that
   the puzzle tiles are still tappable on smaller screens.
   */
  func validate(stringMap: [[String]]) throws -> [[Character]]? {
    guard stringMap.indices.contains(0) else {
      return nil
    }
    let numberRows = stringMap.count
    let numberColumns = stringMap[0].count
    
    guard numberColumns > 2,
          numberColumns < 10, // In practice I probably would limit the grid size even more due to screen real estate
          numberRows > 2,
          numberRows < 10 else {
            throw APIError.gridDimensionsOutOfBounds
    }
    
    //Creates a blank matrix of characters
    var blankMap: [[Character?]]  = Array(repeating: Array(repeating: nil, count: numberColumns), count: numberRows)
    
    //Checks that every string in the character array is convertable to a character, then appends it
    for (i, row) in blankMap.enumerated() {
      for (j, _) in row.enumerated() {
         let stringToConvert = stringMap[i][j]
         if  Array(stringToConvert).count == 1 {
            blankMap[i][j] = Character(stringToConvert.uppercased())
         } else { throw APIError.invalidCharacterInGrid }
      }
    }
    
    //ensures that every slot in the matrix is occupied, else returns nil
    return blankMap as? [[Character]]
  }
  
  
  mutating func markAnswerCorrect(at index: Int) {
    guard answerKey.indices.contains(index) else {
      //
      return
    }
      let answerToMarkCorrect = answerKey.remove(at: index)
      self.completedAnswers.append(answerToMarkCorrect)
  }
  
}

//There should be images that correspond to each of these languages/ could be adapted by user country
enum AvailableLanguage: String {
  case english = "en"
  case spanish = "es"
}

typealias AnswerKey = [(word: String, locations: PathLocations)]
