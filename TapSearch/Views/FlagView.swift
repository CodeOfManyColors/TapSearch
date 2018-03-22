//
//  FlagView.swift
//  TapSearch
//
//

import UIKit

class FlagView: UIView {
  
  @IBOutlet var flagImageHolder: UIImageView!
  
  
/**
  This function requeires that an image with the same name as the language code at the api endpoint is
  preloaded into the application. If there is an image server available, this class could be extended
  to retrieve new images using the APIClient protocol.
*/
  
  func setFlagImage(forLanguage language: AvailableLanguage) {
    guard let flagImage = UIImage(named: language.rawValue) else {
      //Error, try downloading the image for language from server or send error report
      return
    }
    self.flagImageHolder.image = flagImage
  }
}
