//
//  CollectionViewCell.swift
//  Patient Triage
//
//  Created by Vignesh Kumar on 04/07/17.
//  Copyright © 2017 Google Inc. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var btn1: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderColor = UIColor.init(colorLiteralRed: 232.0/255.0, green: 232.0/255.0, blue: 232.0/255.0, alpha: 1.0).cgColor
        btn1.layer.cornerRadius = 5.0
        btn1.layer.borderWidth = 0.5
        btn1.layer.borderColor = UIColor.init(colorLiteralRed: 200.0/255.0, green: 200.0/255.0, blue: 200.0/255.0, alpha: 1.0).cgColor
    }
}
