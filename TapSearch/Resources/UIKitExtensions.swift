//
//  UIKitExtensions.swift
//  TapSearch
//
//

import UIKit

protocol UIViewLoading {}
extension UIView : UIViewLoading {}

extension UIViewLoading where Self : UIView {
  
  // note that this method returns an instance of type `Self`, rather than UIView
  static func loadFromNib() -> Self {
    let nibName = "\(self)".split{$0 == "."}.map(String.init).last!
    let nib = UINib(nibName: nibName, bundle: nil)
    return nib.instantiate(withOwner: self, options: nil).first as! Self
  }
  
}


/*
// stackoverflow.com/questions/25796545/getting-device-orientation-in-swift/31105880
struct DeviceInfo {
  struct Orientation {
    // indicate current device is in the LandScape orientation
    static var isLandscape: Bool {
      get {
        return UIDevice.current.orientation.isValidInterfaceOrientation
          ? UIDevice.current.orientation.isLandscape
          : UIApplication.shared.statusBarOrientation.isLandscape
      }
    }
    // indicate current device is in the Portrait orientation
    static var isPortrait: Bool {
      get {
        return UIDevice.current.orientation.isValidInterfaceOrientation
          ? UIDevice.current.orientation.isPortrait
          : UIApplication.shared.statusBarOrientation.isPortrait
      }
    }
  }
}

struct Device {
  //Device detection code
  var isPad: Bool {
    return UIDevice.current.userInterfaceIdiom == .pad
  }
  var isPhone: Bool {
    return UIDevice.current.userInterfaceIdiom == .phone
  }
  var isRetina: Bool {
    return UIScreen.main.scale >= 2.0
  }
  var screenWidth: CGFloat {
    if UIInterfaceOrientationIsPortrait(screenOrientation) {
      return UIScreen.main.bounds.size.width
    } else {
      return UIScreen.main.bounds.size.height
    }
  }
  var screenHeight: CGFloat {
    if UIInterfaceOrientationIsPortrait(screenOrientation) {
      return UIScreen.main.bounds.size.height
    } else {
      return UIScreen.main.bounds.size.width
    }
  }
  var screenOrientation: UIInterfaceOrientation {
    return UIApplication.shared.statusBarOrientation
  }
  var aspectRatio: CGFloat {
    return screenHeight / screenWidth
  }
  var headerHeight: CGFloat {
    return min(80, screenHeight / 5)
  }
  
  var padding: CGFloat {
    return 30
  }
  var currentDisplayMode: ContentDisplayMode {
    switch aspectRatio {
    case _ where aspectRatio > 1:
      return .vertical
    case _ where aspectRatio <= 1:
      return .horizontal
    default:
      return .vertical
    }
  }
}*/

extension UIColor {
  
  public static var mainTeal: UIColor {
    return UIColor(red: 6/255, green: 157/255, blue: 153/255, alpha: 1)
  }
  public static var dimmedTile: UIColor {
    return UIColor(red: 240/255, green: 240/255, blue: 237/255, alpha: 1)
  }
  public static var dimmedText: UIColor {
    return UIColor(red: 4/255, green: 144/255, blue: 139/255, alpha: 1)
  }
  public static var correctText: UIColor {
    return UIColor(red: 135/255, green: 207/255, blue: 32/255, alpha: 1)
  }
  public static var highlightedTile: UIColor {
    return UIColor(red: 251/255, green: 251/255, blue: 247/255, alpha: 1)
  }
  public static var highlightedBlue: UIColor {
    return UIColor(red: 6/255, green: 195/255, blue: 189/255, alpha: 1)
  }
}


extension UIView {
  func applyGradient(direction: GradientDirection, colorLocationTuple: [(color: CGColor, location: NSNumber)]) {
    
    
    let gradient = CAGradientLayer()
    gradient.colors = colorLocationTuple.map { $0.color } // your colors go here
    gradient.locations = colorLocationTuple.map { $0.location }
    gradient.frame = self.bounds
    
    
    switch direction {
    case .leftToRight:
      gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
      gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
    case .rightToLeft:
      gradient.startPoint = CGPoint(x: 1.0, y: 0.5)
      gradient.endPoint = CGPoint(x: 0.0, y: 0.5)
    case .bottomToTop:
      gradient.startPoint = CGPoint(x: 0.5, y: 1.0)
      gradient.endPoint = CGPoint(x: 0.5, y: 0.0)
    default:
      break
    }
    
    self.layer.insertSublayer(gradient, at: 0)
    
  }
}
  enum GradientDirection {
    case leftToRight
    case rightToLeft
    case topToBottom
    case bottomToTop
  }
  
  enum ContentDisplayMode {
    case vertical
    case horizontal
}

