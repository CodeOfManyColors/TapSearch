//
//  ViewController.swift
//  TapSearch
//
//

import UIKit


class WordPuzzleViewController: UIViewController {
  
  //MARK: Properties
  
  //Associated models/views
  var puzzleStore: PuzzleStore!
  var wordPuzzleView: WordPuzzleView!
  var headerView: HeaderView!
  
  //Path checking
  var letterViews: [[PuzzleLetterView?]]?
  var beginningTile: PuzzleLetterView?
  var currentlyTouchedTile: PuzzleLetterView?
  var reusableTiles = Set<PuzzleLetterView>()
  var tilesInUse = Set<PuzzleLetterView>()
  var currentPath: Path?
  
  //MARK: Controller Lifecycle Methods
  override func viewDidLoad() {
    super.viewDidLoad()
    setupPuzzleStore()
    setupSubviews()
  }
  
  override func loadView() {
    wordPuzzleView = WordPuzzleView.loadFromNib()
    self.view = wordPuzzleView
    self.view.layoutIfNeeded()
    wordPuzzleView.setupSubViews()
  }
  
  func setupPuzzleStore() {
      self.puzzleStore = PuzzleStore()
      
      let parsedPuzzles = self.puzzleStore.retrievePuzzlesOffline()
      parsedPuzzles.forEach { puzzle in
        self.puzzleStore.add(puzzle: puzzle)
      }
      self.stageNextAvailablePuzzle()
      
     /* self.puzzleStore.retrievePuzzles(from: .findChallenges, completion: {result in
        switch result {
        case .success(let wordPuzzleArray):          
          for puzzle in wordPuzzleArray {
            self.puzzleStore.add(puzzle: puzzle)
          }
          
          self.stageNextAvailablePuzzle()
          
        case .failure(let error):
          print("the error \(error)")
        }
      })*/
    
  }
  
  private func stageNextAvailablePuzzle() {
    if let firstPuzzle = self.puzzleStore.getNextPuzzle() {
      self.transitionTo(nextPuzzle: firstPuzzle)
      self.wordPuzzleView.puzzleContainer.setNextButtonInteractionState(enabled: true)
    } else {
      self.wordPuzzleView.puzzleContainer.setNextButtonInteractionState(enabled: false)
    }
  }
  
  
  func setupSubviews() {
    self.view.backgroundColor = UIColor.mainTeal
    
    wordPuzzleView.puzzleContainer.nextButton.addTarget(self,
                                         action: #selector(didPressNextPuzzleButton),
                                         for: .touchUpInside)
  }
  
  //MARK: Puzzle grid
  
  fileprivate func formatUserPrompt(_ solutionsLeft: Int) -> String {
    switch solutionsLeft {
    case 0:
      return "COMPLETE!"
    case 1:
      return "1 TRANSLATION TO GO!"
    case 2...99:
     return "\(solutionsLeft) TRANSLATIONS TO GO!"
    default:
      return ""
    }
  }
  
  /**
   This method advances the UI to the next puzzle and resizes the
   grid to accomodate the puzzle size
   */
  func show(puzzle: WordPuzzle) {
    
    //Recycle Tiles
    tilesInUse.forEach({
      $0.removeFromSuperview()
    })
    self.reusableTiles = self.reusableTiles.union(self.tilesInUse)
    self.tilesInUse = Set<PuzzleLetterView>()
    
    //Set flag language and prompt user to find other available solutions
    self.wordPuzzleView.headerView.originalLanguageFlag!.setFlagImage(forLanguage: puzzle.enumSource)
    self.wordPuzzleView.headerView.translatedLanguageFlag!.setFlagImage(forLanguage: puzzle.enumTarget)
    let characterGrid = puzzle.characterGrid
    wordPuzzleView.headerView.set(labelText: formatUserPrompt(puzzle.answerKey.count))
    
    if self.puzzleStore.unseenPuzzleCount == 0  {
      self.wordPuzzleView.puzzleContainer.setNextButtonInteractionState(enabled: false)
      //self.puzzleStore.retrievePuzzles()
    }

    self.wordPuzzleView.headerView.titleLabel.text = puzzle.word.uppercased()
    layoutTilesOnWordGrid(characterGrid)
  }
  
  
  /**
   Finds every subview that can be cast as a PuzzleLetterView and resets
   the display state to normal. Called during the user touch interaction
   to highlight user tiles
   */
  func clearAllTiles() {
    self.currentPath = nil
    
    UIView.animate(withDuration: 0.1, animations: {
      self.wordPuzzleView.puzzleContainer.wordGrid.subviews.flatMap({ $0 as? PuzzleLetterView})
                                            .filter{ $0.getCurrentState() == .minimized}
                                            .forEach {(letterview) in
                                              letterview.changeState(letterview.getPreviousState(), animated: true)
                                            }
      
      self.wordPuzzleView.puzzleContainer.wordGrid.subviews.flatMap({$0 as? PuzzleLetterView})
                                            .filter{ $0.getCurrentState() == .highlighted }
                                            .forEach({(letterview) in
                                              letterview.changeState(letterview.getPreviousState(), animated: true)
                                            })
      self.view.layoutIfNeeded()
    })
  }
  
  /**
   Handles the mathmatics of laying out the the lettergrid. Tiles are sized
   as a ratio of their parent view, the word grid
   */
  func layoutTilesOnWordGrid(_ characterGrid: [[Character]]) {
    let letterViewWidth = self.wordPuzzleView.puzzleContainer.wordGrid.bounds.width / CGFloat(characterGrid.count)
    let letterViewHeight = self.wordPuzzleView.puzzleContainer.wordGrid.bounds.height / CGFloat(characterGrid[0].count)
    self.letterViews = Array(repeating: Array(repeating: nil, count: characterGrid.count), count: characterGrid[0].count)
    
    for (i, row) in characterGrid.enumerated() {
      for (j, letter) in row.enumerated() {
        var letterView: PuzzleLetterView?
        if reusableTiles.count > 0 {
          letterView = reusableTiles.popFirst()
        } else {
          letterView = PuzzleLetterView.loadFromNib()
        }
        letterView!.frame = CGRect(origin: CGPoint(x: CGFloat(i) * letterViewWidth,
                                                   y: CGFloat(j) * letterViewHeight),
                                   size: CGSize(width: letterViewWidth,
                                                height: letterViewHeight))
        letterView!.stageTile(forCharacter: letter)
        self.wordPuzzleView.puzzleContainer.wordGrid.addSubview(letterView!)
        self.tilesInUse.insert(letterView!)
        letterViews![i][j] = letterView
        letterView!.set(tileLocation: TileLocation(x: i, y: j))
      }
    }
  }
  //MARK: Touch Controls
  
  /**
   Checks whether the user is touching a tile, if so it creates a path object
   and marks the current tile as the beginning of the path.
   */
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let touchedTile = checkIfTouchingTile(location: touches.first!.location(in: self.view), event: event) {
      if let path = validPathBetween(startingTile: touchedTile, touchedTile: touchedTile) {
        self.highlight(path: path)
      }
      self.beginningTile = touchedTile
      self.currentlyTouchedTile = touchedTile
    }
  }
  
  /**
   Updates the user's path as they drag their finger. Checks whether the user
   is touching a tile that is either:
   - horizontal,
   - vertical
   - diagonal
   in relation to the starting tile. If so it highlights the path, else it clears
   out any path highlighting
   */
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let touchedTile = checkIfTouchingTile(location: touches.first!.location(in: self.view), event: event),
      let startingTile = self.beginningTile {
      
      //Only run if the user is actually touching a new tile
      guard let previouslyTouchedTile = self.currentlyTouchedTile,
        previouslyTouchedTile != touchedTile else {
          //Touch hasn't changed
          return
      }
      //Check whether new touch is valid
      self.currentlyTouchedTile = touchedTile
      if let path = validPathBetween(startingTile: startingTile, touchedTile: touchedTile) {
        self.highlight(path: path)
      } else {
        clearAllTiles()
      }
      
    } else if touchingWordGrid(location: touches.first!.location(in: self.view), event: event) {
      //Do nothing, user touching corners of tiles
      
    } else {
      clearAllTiles()
      return
    }
  }
  
  /**
   Checks for valid path between beginning and currently touched tile. If the
   path is valid it then checks whether that path is a valid answer to the puzzle.
   */
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    //Touch hasn't moved
    if let previouslyTouchedTile = self.currentlyTouchedTile,
      let startingTile = self.beginningTile,
      let path = validPathBetween(startingTile: startingTile, touchedTile: previouslyTouchedTile) {
      if let currentPuzzle = puzzleStore.getCurrentPuzzle() {
        if let solutionNumber = checkAnswer(currentPuzzle: currentPuzzle, path: path) {
          handleCorrectAnswer(currentPuzzle: currentPuzzle, path: path, solutionNumber: solutionNumber)
        }
      }
    } else if let touchedTile = checkIfTouchingTile(location: touches.first!.location(in: self.view), event: event),
      let startingTile = self.beginningTile,
      let path = validPathBetween(startingTile: startingTile, touchedTile: touchedTile) {
      if let currentPuzzle = puzzleStore.getCurrentPuzzle() {
        if let solutionNumber = checkAnswer(currentPuzzle: currentPuzzle, path: path) {
          handleCorrectAnswer(currentPuzzle: currentPuzzle, path: path, solutionNumber: solutionNumber)
        }
      }
    }
    self.beginningTile = nil
    self.currentlyTouchedTile = nil
    clearAllTiles()
  }
  
  /**
   Checks whether the user is tapping the visible part of the tile.
   If so, it returns a reference to the PuzzleLetterView
   */
  func checkIfTouchingTile(location: CGPoint, event: UIEvent?) -> PuzzleLetterView? {
    let hitView = self.view.hitTest(location, with: event)
    for letterTile in (self.wordPuzzleView.puzzleContainer.wordGrid.subviews).flatMap({ $0 as? PuzzleLetterView}) {
      if hitView === letterTile.backgroundShapeView {
        return letterTile
      }
    }
    return nil
  }
  
  /**
   Checks whether the set of path objects provided by the API match the path
   that the user traced with their finger. If so, it returns the index number of the correct
   answer to be handles by the 'handleCorrectAnswer' function
   
   This function currently allows users to swipe to get the answer in any order they want,
   if could easly enforce swipe direction if desired by guarding that:
   
   path.start == solution.start
   path.end == solution.end
   */
  func checkAnswer(currentPuzzle: WordPuzzle, path: Path) -> Int? {
    
      for (i, solution) in currentPuzzle.answerKey.enumerated() {
        
        //If the path and solution are equivalent
        if path.locations == solution.locations {
          return i
        }
      }
    
    //didn't find a solution
    return nil
  }
  
  
  /**
   This marks the tile that were part of the solution correct and transitions to the next puzzle
   */
  func handleCorrectAnswer(currentPuzzle: WordPuzzle, path: Path, solutionNumber: Int) {
    if let tiles = letterViews {
      //Mark all tiles that were part of the solution
      for location in path.locations {
        if let tileAtLocation = tiles[location.x][location.y] {
          tileAtLocation.changeState(.correct, animated: true)
        } else {
          //handle error
          return
        }
      }
    }
    
    //To handle mutating struct
    var puzzleCopy = currentPuzzle
    
    //Remove this particular answer from the tasks and install copy as current puzzle
    puzzleCopy.markAnswerCorrect(at: solutionNumber)
    self.puzzleStore.updateCurrentPuzzle(struct: puzzleCopy)
    self.wordPuzzleView.headerView.set(labelText: formatUserPrompt(puzzleCopy.answerKey.count))
    
    if puzzleCopy.answerKey.count == 0 {
      if let nextPuzzle = self.puzzleStore.getNextPuzzle() {
        //celebrate(completion: {
        transitionTo(nextPuzzle: nextPuzzle)
        //})
      } else {
        //Handle finishing all puzzles.....placeholder for proper app flow
        self.wordPuzzleView.puzzleContainer.nextButton.setTitle("COMPLETE!", for: .disabled)
        self.wordPuzzleView.puzzleContainer.nextButton.setTitleColor(.lightGray, for: .disabled)
        //self.puzzleStore.retrievePuzzles()
      }
    }
  }
  /**
   Visual transition to next puzzle:
   Fades out -> Lays out new puzzle -> Fades in
   */
  func transitionTo(nextPuzzle: WordPuzzle) {
    self.wordPuzzleView.puzzleContainer.fadeAlpha(to: 0, completion: { finished in
      self.show(puzzle: nextPuzzle)
      self.wordPuzzleView.puzzleContainer.fadeAlpha(to: 1, completion: { finished in
        
      })
    })
  }
  
  /**
   Determines whether the user is touching the PuzzleWordGridView behind the tiles,
   (NOT the tiles, NOT the PuzzleContainerView)
   
   This helps to prevent flashing when tracing the diagonal
   */
  func touchingWordGrid(location: CGPoint, event: UIEvent?) -> Bool {
    let hitView = self.view.hitTest(location, with: event)
    
    if hitView === self.wordPuzzleView.puzzleContainer.wordGrid {
      return true
    } else {
      for letterTile in (self.wordPuzzleView.puzzleContainer.wordGrid.subviews).flatMap({ $0 as? PuzzleLetterView}) {
        
        if hitView === letterTile || hitView === self.wordPuzzleView.puzzleContainer.wordGrid {
          return true
        }
      }
    }
    return false
  }
  
  /**
   Allows the user to manually advance in the case that they get stuck on a puzzle
   */
  @objc func didPressNextPuzzleButton(sender: UIButton) {
    if let nextPuzzle = self.puzzleStore.getNextPuzzle() {
      transitionTo(nextPuzzle: nextPuzzle)
    } else {
      // No More Puzzles
      //animate button
    }
  }
  
  
  //MARK: Answer Checking
  
  /**
   A valid path is defined as a path between tiles that are either positioned vertically, horizontally or (1-to-1) diagonally in reference to each other. This function checks
   whether the tiles are in a valid orientation, if so, it returns a Path object that descibes
   the path traced by the user
   */
  
  func validPathBetween(startingTile: PuzzleLetterView, touchedTile: PuzzleLetterView) -> Path? {
    guard let start = startingTile.getLocation(),
      let end   = touchedTile.getLocation() else {
        // Send Error report, something is seriously wrong
        return nil
    }
    
    let deltaX: Int = abs(start.x - end.x)
    let deltaY: Int = abs(start.y - end.y)
    let distance = max(deltaX, deltaY)
    
    switch (deltaX, deltaY) {
    case (0, _):           //Vertical   / Single Tile
      return pathBetweenTiles(start: start, end: end, iterations: distance)
    case (_, 0):           //Horizontal / Single Tile
      return pathBetweenTiles(start: start, end: end, iterations: distance)
    case (deltaX, deltaX): //Diagonal   / Single Tile
      return pathBetweenTiles(start: start, end: end, iterations: distance)
    default:               //invalid path
      return nil
    }
  }
  
  /**
   Initializes a Path object given a starting and ending tile.
   */
  func  pathBetweenTiles(start: TileLocation, end: TileLocation, iterations: Int) -> Path {
    
    var xStep = 0
    switch start.x {
    case end.x:
      break
    case Int.min..<end.x:
      xStep =  1
    case (end.x + 1)...Int.max:
      xStep = -1
    default:
      print("Error")
    }
    
    var yStep = 0
    switch start.y {
    case end.y:
      break
    case Int.min..<end.y:
      yStep =  1
    case (end.y + 1)...Int.max:
      yStep = -1
    default:
      print("Error")
    }
    
    var pathLocations = Set<TileLocation>()
    var i = 0
    for _ in 0...iterations {
      let newX = start.x + xStep * i
      let newY = start.y + yStep * i
      pathLocations.insert(TileLocation(x: newX, y: newY))
      i += 1
    }
    
    let path = Path(locations: pathLocations, start: start, end: end)
    return path
  }
  
  /**
   Takes a path object as an argument and visually highlights each of the tiles present in
   the path for the user.
   */
  func highlight(path: Path) {
    guard let tiles = letterViews else { return }
    if currentPath != nil {
      //clears old path tiles not in the current path
      let tilesToBeCleared = currentPath!.locations.subtracting(path.locations)
      tilesToBeCleared.forEach( {
        if let tileToClear = tiles[$0.x][$0.y] {
          if tileToClear.getCurrentState() == .highlighted {
            tileToClear.changeState(tileToClear.getPreviousState(), animated: true)
          }
        } else {
          // Indicates that tile was pressed whcih isn't present in the model
          // May be a UI Glitch / dead tile
          // Send Error analytic
        }
      })
    }
    
    self.currentPath = path
    for location in path.locations {
      self.view.layer.removeAllAnimations()

      if let tileAtLocation = tiles[location.x][location.y] {
        tileAtLocation.layer.removeAllAnimations()
        tileAtLocation.changeState(.highlighted, animated: true)
      } else {
        //handle error
        return
      }
    }
     UIView.animate(withDuration: 0.1, animations: {
      //Minimize all cells which are at resting state (not highlighted)
      self.tilesInUse.filter{ [.normal, .correct].contains($0.getCurrentState()) }.forEach { (letter) in
        letter.changeState(.minimized, animated: true)
      }
    })
  }
 
}




