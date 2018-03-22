//
//  PuzzleLetterView.swift
//  TapSearch
//
//

import UIKit

class PuzzleLetterView: UIView {
  
  @IBOutlet var letterLabel: UILabel!
  @IBOutlet var letterHeight: NSLayoutConstraint!
  @IBOutlet var letterWidth: NSLayoutConstraint!
  @IBOutlet var backgroundShapeView: UIView!
  
  private var currentState: LetterState = .normal
  private var previousRestingState: LetterState = .normal
  private var location: TileLocation?
  
  
  func initializeAesthetics() {
    
    self.letterLabel.font = UIFont(name: "Geeza Pro", size: CGFloat(0.5 * self.bounds.width))

    self.clipsToBounds = false
    resetAesthetics()
    
    //Removing clear background improves animation performance
    //self.letterLabel.backgroundColor = self.backgroundShapeView.backgroundColor
  }
  
  func resetAesthetics() {
    
    self.letterLabel.font = UIFont(name: "Geeza Pro", size: CGFloat(0.5 * self.bounds.width))

    self.letterHeight.constant = self.bounds.height * 0.9
    self.letterWidth.constant = self.bounds.width * 0.9
    
    self.backgroundShapeView.layer.shadowOffset = CGSize(width: 0, height: 1)
    self.backgroundShapeView.layer.shadowColor = UIColor.darkGray.cgColor
    self.backgroundShapeView.layer.shadowOpacity = 0.25
    if self.backgroundShapeView.layer.cornerRadius != self.bounds.width * 0.5 / 2 {
      self.backgroundShapeView.layer.cornerRadius = self.bounds.width * 0.5 / 2
    }
    self.letterLabel.textColor =  .dimmedText
    self.backgroundShapeView.backgroundColor = .highlightedTile
  }
  
  //MARK: Handle state
  func getCurrentState() -> LetterState {
    return currentState
  }
  
  func getPreviousState() -> LetterState {
    return previousRestingState
  }
  
  func set(previousState: LetterState) {
    self.previousRestingState = previousState
  }
  
  func changeState(_ state: LetterState, animated: Bool) {
    switch state {
    case .highlighted:
      
      if animated {
        UIView.animate(withDuration: 1,
                       delay: 0,
                       usingSpringWithDamping: 0.1,
                       initialSpringVelocity: 8,
                       options: [.allowUserInteraction, .beginFromCurrentState],
                       animations: {
                        self.backgroundShapeView.layer.cornerRadius = self.bounds.width / 2.4
                        self.backgroundShapeView.layer.shadowOffset = CGSize(width: 0, height: 4)
                        self.backgroundShapeView.layer.shadowColor = UIColor.darkGray.cgColor
                        self.backgroundShapeView.layer.shadowOpacity = 0.3
        })
      } else {
        self.backgroundShapeView.layer.cornerRadius = self.bounds.width / 2.4
        self.backgroundShapeView.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.backgroundShapeView.layer.shadowColor = UIColor.darkGray.cgColor
        self.backgroundShapeView.layer.shadowOpacity = 0.3
      }
      
      switch self.currentState {
      case .correct:
        self.frame.origin.y -= 15
        self.previousRestingState = self.currentState
        
      case .normal:
        self.frame.origin.y -= 15
        self.previousRestingState = self.currentState
        
      case .minimized:
        self.frame.origin.y -= 15
      default:
        break
      }
      self.currentState = state
      
      self.letterLabel.textColor = UIColor.mainTeal
      self.backgroundShapeView.backgroundColor = .highlightedTile
      
    case .minimized:
      
      //Record previous state and adjust y position
      switch self.currentState {
      case .correct:
        self.previousRestingState = self.currentState
      case .normal:
        self.previousRestingState = self.currentState
      case .highlighted:
        self.frame.origin.y += 15
      default:
        break
      }
      
      //Dim the tile view
      self.currentState = state
      self.letterLabel.textColor =  .dimmedText
      //self.backgroundShapeView.backgroundColor = .dimmedTile
      //if self.backgroundShapeView.layer.cornerRadius != self.bounds.width * 0.5 / 2 {
      //  self.backgroundShapeView.layer.cornerRadius = self.bounds.width * 0.5 / 2
      //}
      
    case .normal:
      
      switch self.currentState {
      case .highlighted:
        self.frame.origin.y += 15
      default:
        break
      }
      
      self.currentState = state
      self.resetAesthetics()
      
    case .correct:
      
      self.previousRestingState = self.currentState
      
      //Send tiles back to neutral y position
      switch self.currentState {
      case .highlighted:
        self.frame.origin.y += 15
      default:
        break
      }
      
      //Keep highlighted color properties and shape
      self.currentState = state
      self.backgroundShapeView.layer.cornerRadius = letterWidth.constant / 2
      self.backgroundShapeView.layer.shadowOffset = CGSize(width: 0, height: 1)
      self.backgroundShapeView.layer.shadowColor = UIColor.darkGray.cgColor
      self.backgroundShapeView.layer.shadowOpacity = 0.25
      self.letterLabel.textColor = UIColor.correctText
      self.backgroundShapeView.backgroundColor = .highlightedTile
      
    case .loading:
      self.backgroundShapeView.backgroundColor = .darkGray
    }
  }
  
  func set(character: Character) {
    self.letterLabel.text = String(describing: character)
  }
  
  func set(tileLocation: TileLocation) {
    self.location = tileLocation
  }
  
  func getLocation() -> TileLocation? {
    return self.location
  }
  
  func stageTile(forCharacter character: Character) {
    set(character: character)
    self.previousRestingState = .normal
    self.changeState(.normal, animated: true)
    self.location = nil
  }
  
  enum LetterState {
    case loading      // In the case that you load each puzzle from api individually
    case highlighted  // When part of a path selected by the used
    case correct      // Tile that was previously included in the path of a correct answer
    case minimized    // Tile which is not part of the currently selected path
    case normal       // Resting state
  }
}
