//
//  PuzzleContainerView.swift
//  TapSearch
//
//

import UIKit
import SpriteKit

class PuzzleContainerView: UIView {

  @IBOutlet var nextButton: UIButton!
  var wordGrid: PuzzleWordGridView!
  
  /**
   Sizes wordgrid
   */
  
  func setupWordGrid() {
    wordGrid = PuzzleWordGridView.loadFromNib()
    self.addSubview(wordGrid)
    self.layoutIfNeeded()

    wordGrid.translatesAutoresizingMaskIntoConstraints = false
    layoutWordGrid()
  }

  func layoutWordGrid() {

    let availableYSpace = self.nextButton.frame.minY - 100
    let availableXSpace = self.bounds.width - 30
    
    let gridDimension = min(availableXSpace, availableYSpace)
    let gridSizingContstraint = NSLayoutConstraint(item: wordGrid!, attribute: .width , relatedBy: .equal , toItem: nil, attribute: .width, multiplier: 1, constant: gridDimension)
    gridSizingContstraint.priority = UILayoutPriority(rawValue: 995)
      gridSizingContstraint.isActive = true
    NSLayoutConstraint(item: wordGrid!, attribute: .height, relatedBy: .equal, toItem: wordGrid!, attribute: .width, multiplier: 1, constant: 0).isActive = true
    NSLayoutConstraint(item: wordGrid!, attribute: .centerX , relatedBy: .equal, toItem: self, attribute: .centerX,
                       multiplier: 1, constant: 0).isActive = true
    NSLayoutConstraint(item: wordGrid!, attribute: .centerY , relatedBy: .equal, toItem: self, attribute: .centerY,
                       multiplier: 1, constant:  0).isActive = true
    NSLayoutConstraint(item: wordGrid!, attribute: .width , relatedBy: .lessThanOrEqual , toItem: nil, attribute: .width,
                       multiplier: 1, constant: 530).isActive = true
    NSLayoutConstraint(item: wordGrid!, attribute: .width , relatedBy: .greaterThanOrEqual , toItem: nil, attribute: .width,
                       multiplier: 1, constant: 320).isActive = true
    self.layoutIfNeeded()


  }
  /**
   Determines the placement and sizing of the next button. Any updates are done by the
   updatesView button
   */
  func setupNextButton(){
    
    nextButton.backgroundColor = .highlightedBlue
    nextButton.titleLabel?.font  = UIFont(name: "Geeza Pro", size: 18)
    nextButton.setTitle("SKIP PUZZLE", for: .normal)
    nextButton.setTitleColor(.white, for: .normal)
    nextButton.setTitleColor(.gray, for: .selected)
    nextButton.setTitle("SKIP PUZZLE!", for: .disabled)
    nextButton.setTitleColor(.lightGray, for: .disabled)
    nextButton.layer.shadowOffset = CGSize(width: 0, height: 5)
    nextButton.layer.shadowColor = UIColor.darkGray.cgColor
    nextButton.layer.shadowOpacity = 0.2
    nextButton.layer.cornerRadius = nextButton.bounds.height / 2

    self.addSubview(nextButton)
  }
  
  
  /**
   Animates the alpha of all subviews to specified level over time. Completion allows chaining of animations
   */
  func fadeAlpha(to alpha: CGFloat, completion: @escaping (Bool) -> ()) {
    UIView.animate(withDuration: 0.3, animations: {
      self.subviews.forEach({(view) in
          view.alpha = alpha
      })
    }, completion: { finished in
      completion(true)
    })
  }
  
  /**
   Toggle between active and inactive states.
   */
  func setNextButtonInteractionState(enabled: Bool){
    switch enabled{
    case true:
      nextButton.isEnabled = true
      nextButton.backgroundColor = .highlightedBlue

    case false:
      nextButton.isEnabled = false
      nextButton.backgroundColor = .gray
    }
  }
}

