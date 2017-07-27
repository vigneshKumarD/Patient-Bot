//
//  ChatTableViewCell.swift
//  Patient Triage
//
//  Created by Vignesh Kumar on 29/06/17.
//  Copyright © 2017 Google Inc. All rights reserved.
//

import UIKit

class ChatTableViewCell: UITableViewCell {

    @IBOutlet weak var imgUserImage: UIImageView!
    @IBOutlet weak var lblChatText: UILabel!
    @IBOutlet weak var layoutImageW: NSLayoutConstraint!
    @IBOutlet weak var layoutTrailingText: NSLayoutConstraint!
    @IBOutlet weak var layoutLeadingText: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
class StackCellInTableview: UITableViewCell {
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
