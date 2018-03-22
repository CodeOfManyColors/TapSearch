//
//  WordPuzzleView.swift
//  TapSearch
//
//

import UIKit

class WordPuzzleView: UIView {
  
  var puzzleContainer: PuzzleContainerView!
  var headerView: HeaderView!
  
  override func awakeFromNib() {
    self.bounds = UIScreen.main.bounds
    self.setupSubViews()
  }
  
  func setupSubViews() {
    puzzleContainer = PuzzleContainerView.loadFromNib()
    self.addSubview(puzzleContainer!)
    puzzleContainer!.translatesAutoresizingMaskIntoConstraints = false

    headerView = HeaderView.loadFromNib()
    self.addSubview(headerView!)
    headerView!.translatesAutoresizingMaskIntoConstraints = false
   
    
    if #available(iOS 11.0, *) {
      let guide = self.safeAreaLayoutGuide
      NSLayoutConstraint(item: headerView!, attribute: .top , relatedBy: .equal, toItem: guide, attribute: .top,
                         multiplier: 1.0, constant: 0.0).isActive = true
    } else {
      NSLayoutConstraint(item: headerView!, attribute: .top , relatedBy: .equal, toItem: self, attribute: .top,
                         multiplier: 1.0, constant: 0.0).isActive = true
    }
    NSLayoutConstraint(item: headerView!, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading,
                       multiplier: 1.0, constant: 0.0).isActive = true
    NSLayoutConstraint(item: headerView!, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing,
                       multiplier: 1.0, constant: 0.0).isActive = true
    let scalableHeight = NSLayoutConstraint(item: headerView!, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0.1, constant: 0)
    scalableHeight.priority = UILayoutPriority(rawValue: 990)
    scalableHeight.isActive = true
    
    NSLayoutConstraint(item: headerView!, attribute: .height, relatedBy: .lessThanOrEqual, toItem: nil, attribute: .height,
                       multiplier: 1, constant: 70).isActive = true
    NSLayoutConstraint(item: headerView!, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .height,
                       multiplier: 1, constant: 40).isActive = true
    
    NSLayoutConstraint(item: puzzleContainer!,attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading,
                       multiplier: 1, constant: 0.0).isActive = true
    NSLayoutConstraint(item: puzzleContainer!, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing,
                       multiplier: 1, constant: 0.0).isActive = true
    NSLayoutConstraint(item: puzzleContainer!, attribute: .top , relatedBy: .equal, toItem: headerView!, attribute: .bottom,
                       multiplier: 1, constant: 0).isActive = true
    NSLayoutConstraint(item: puzzleContainer!, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom,
                       multiplier: 1, constant: 0).isActive = true
    self.layoutIfNeeded()
    
    puzzleContainer.setupWordGrid()
    puzzleContainer.setupNextButton()
    
  }
  
  
}
