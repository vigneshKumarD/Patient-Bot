//
//  OptionsCollectionCell.swift
//  Patient Triage
//
//  Created by Vignesh Kumar on 05/07/17.
//  Copyright © 2017 Google Inc. All rights reserved.
//

import UIKit

class OptionsCollectionCell: UICollectionViewCell {

    @IBOutlet weak var btnText1: UIButton!
    @IBOutlet weak var btnText2: UIButton!
    @IBOutlet weak var btnText3: UIButton!
    @IBOutlet weak var btnText4: UIButton!
    @IBOutlet weak var btnText5: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    
        
        self.layer.cornerRadius = 10.0
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.init(colorLiteralRed: 200.0/255.0, green: 200.0/255.0, blue: 200.0/255.0, alpha: 1.0).cgColor
        
        btnText1.layer.cornerRadius = 5.0
        btnText1.layer.borderWidth = 0.5
        btnText1.layer.borderColor = UIColor.init(colorLiteralRed: 200.0/255.0, green: 200.0/255.0, blue: 200.0/255.0, alpha: 1.0).cgColor
        
        btnText2.layer.cornerRadius = 5.0
        btnText2.layer.borderWidth = 0.5
        btnText2.layer.borderColor = UIColor.init(colorLiteralRed: 200.0/255.0, green: 200.0/255.0, blue: 200.0/255.0, alpha: 1.0).cgColor
        
        btnText3.layer.cornerRadius = 5.0
        btnText3.layer.borderWidth = 0.5
        btnText3.layer.borderColor = UIColor.init(colorLiteralRed: 200.0/255.0, green: 200.0/255.0, blue: 200.0/255.0, alpha: 1.0).cgColor
        
        btnText4.layer.cornerRadius = 5.0
        btnText4.layer.borderWidth = 0.5
        btnText4.layer.borderColor = UIColor.init(colorLiteralRed: 200.0/255.0, green: 200.0/255.0, blue: 200.0/255.0, alpha: 1.0).cgColor
        
          }

    
}
