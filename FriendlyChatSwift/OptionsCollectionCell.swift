//
//  OptionsCollectionCell.swift
//  Patient Triage
//
//  Created by Vignesh Kumar on 05/07/17.
//  Copyright © 2017 Google Inc. All rights reserved.
//

import UIKit

class OptionsCollectionCell: UICollectionViewCell {
    
    
    @IBOutlet weak var imgLogo: UIImageView!
    
    @IBOutlet weak var labelText: UILabel!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
            
        self.layer.cornerRadius = 5.0
//        self.layer.borderWidth = 0.5
//        self.layer.borderColor = UIColor.init(colorLiteralRed: 200.0/255.0, green: 200.0/255.0, blue: 200.0/255.0, alpha: 1.0).cgColor
        self.layer.backgroundColor = UIColor.init(colorLiteralRed: 232.0/255.0, green: 232.0/255.0, blue: 232.0/255.0, alpha: 1.0).cgColor
        
        imgLogo.layer.cornerRadius = 5.0
        imgLogo.layer.borderWidth = 0.5
        imgLogo.layer.borderColor = UIColor.init(colorLiteralRed: 200.0/255.0, green: 200.0/255.0, blue: 200.0/255.0, alpha: 1.0).cgColor
        imgLogo.clipsToBounds = true
        
        labelText.layer.cornerRadius = 5.0
        labelText.layer.borderWidth = 0.5
        labelText.layer.borderColor = UIColor.init(colorLiteralRed: 200.0/255.0, green: 200.0/255.0, blue: 200.0/255.0, alpha: 1.0).cgColor
        labelText.clipsToBounds = true

        
        }

    
}
