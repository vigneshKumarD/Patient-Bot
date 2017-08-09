//
//  SerachTermCell.swift
//  Patient Triage
//
//  Created by Vignesh Kumar on 09/08/17.
//  Copyright © 2017 Google Inc. All rights reserved.
//

import UIKit

class SerachTermCell: UITableViewCell {

    @IBOutlet weak var imgPatient: UIImageView!

    @IBOutlet weak var lbltext: UILabel!
    
    @IBOutlet weak var imgBotImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
