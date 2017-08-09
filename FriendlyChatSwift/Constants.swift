//
//  Copyright (c) 2015 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit
struct Constants {

  struct NotificationKeys {
    static let SignedIn = "onSignInCompleted"
  }

  struct Segues {
    static let SignInToFp = "SignInToFP"
    static let FpToSignIn = "FPToSignIn"
  }

  struct MessageFields {
    static let name = "name"
    static let text = "text"
    static let speech = "speech"
    static let photoURL = "photoURL"
    static let imageURL = "imageURL"
    static let parameters  = "item"
  }
}


//ChatTableViewCell customization

class Customlabel: UILabel {
 
override func drawText(in rect: CGRect) {
    let insets = UIEdgeInsets.init(top: 0, left:12, bottom: 0, right: 12)
    super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
}

//extension CALayer {
//    
//    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
//        
//        let border = CALayer()
//        
//        switch edge {
//        case UIRectEdge.top:
//            border.frame = CGRect.init(x: 0, y: 0, width: self.frame.height, height: thickness)
//            break
//        case UIRectEdge.bottom:
//            border.frame = CGRect.init(x: 0, y: self.frame.height - thickness, width:  UIScreen.main.bounds.width, height: thickness)
//            break
//        case UIRectEdge.left:
//            border.frame = CGRect.init(x: 0, y: 0, width:thickness, height: self.frame.height)
//            break
//        case UIRectEdge.right:
//            border.frame = CGRect.init(x: self.frame.height - thickness, y: 0, width:thickness, height: self.frame.height)
//            break
//        default:
//            break
//        }
//        
//        border.backgroundColor = color.cgColor;
//        
//        self.addSublayer(border)
//    }

//}

