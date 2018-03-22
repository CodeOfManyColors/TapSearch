//
//  HeaderView.swift
//  TapSearch
//
//

import UIKit

class HeaderView: UIView {
  
  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var translationLabel: UILabel!
  @IBOutlet var labelContainer: UIView!
  @IBOutlet var colorHeader: UIView!
  var originalLanguageFlag: FlagView?
  var translatedLanguageFlag: FlagView?
  
  override func awakeFromNib() {
    
    initializeAesthetics()
    setupSubviews()
  }
  
  func initializeAesthetics() {
    self.labelContainer.clipsToBounds = true

    self.layer.shadowOffset = CGSize(width: 0, height: 5)
    self.layer.shadowColor = UIColor.darkGray.cgColor
    self.layer.shadowOpacity = 0.2
    self.clipsToBounds = false
  }
  
  /**
   Creates Flag and translation label subviews
   */
  func setupSubviews() {    
    translatedLanguageFlag = FlagView.loadFromNib()
    self.insertSubview(translatedLanguageFlag!, belowSubview: labelContainer)
    translatedLanguageFlag!.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint( item: translatedLanguageFlag!, attribute: .width, relatedBy: .equal, toItem: labelContainer, attribute: .height, multiplier: 1, constant: 0).isActive = true
    NSLayoutConstraint(item: translatedLanguageFlag!, attribute: .centerX, relatedBy: .equal, toItem: labelContainer, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
    NSLayoutConstraint(item: translatedLanguageFlag!, attribute: .centerY, relatedBy: .equal, toItem: labelContainer, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
    NSLayoutConstraint(item: translatedLanguageFlag!, attribute: .height, relatedBy: .equal, toItem: translationLabel, attribute: .height, multiplier: 1, constant: 0).isActive = true
    
    originalLanguageFlag = FlagView.loadFromNib()
    self.insertSubview(originalLanguageFlag!, belowSubview: labelContainer)
    originalLanguageFlag!.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint( item: originalLanguageFlag!, attribute: .width, relatedBy: .equal, toItem: labelContainer, attribute: .height, multiplier: 1, constant: 0).isActive = true
    NSLayoutConstraint(item: originalLanguageFlag!, attribute: .centerX, relatedBy: .equal, toItem: labelContainer, attribute: .leading, multiplier: 1.0, constant:0).isActive = true
    NSLayoutConstraint(item: originalLanguageFlag!, attribute: .centerY, relatedBy: .equal, toItem: labelContainer, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
    NSLayoutConstraint(item: originalLanguageFlag!, attribute: .height, relatedBy: .equal, toItem: translationLabel, attribute: .height, multiplier: 1, constant: 0).isActive = true
    
    self.layoutIfNeeded()
    self.labelContainer.layer.cornerRadius = self.labelContainer.bounds.height / 2

  }
  
  func set(labelText: String) {
    self.translationLabel.text = labelText
  }
}
