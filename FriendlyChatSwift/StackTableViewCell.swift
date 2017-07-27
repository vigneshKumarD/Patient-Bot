//
//  StackTableViewCell.swift
//  Patient Triage
//
//  Created by Vignesh Kumar on 04/07/17.
//  Copyright © 2017 Google Inc. All rights reserved.
//

import UIKit

class StackTableViewCell: UITableViewCell {

    
   
    @IBOutlet weak var collectionView: UICollectionView!
      
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        collectionView.layer.cornerRadius = 10.0
//        collectionView.layer.borderWidth = 1.0
//        collectionView.layer.borderColor = UIColor.gray.cgColor
        
        collectionView.register(UINib.init(nibName: "OptionsCollectionCell", bundle: nil), forCellWithReuseIdentifier: "optionsCell")
        
        
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

    extension StackTableViewCell  {
        
        func setCollectionViewDataSourceDelegate<D: UICollectionViewDataSource & UICollectionViewDelegate>(_ dataSourceDelegate: D, forRow row: Int) {
            
            collectionView.delegate = dataSourceDelegate
            collectionView.dataSource = dataSourceDelegate
            collectionView.tag = row
            collectionView.setContentOffset(collectionView.contentOffset, animated:false) // Stops collection view if it was scrolling.
            collectionView.reloadData()
        }
        
        var collectionViewOffset: CGFloat {
            set { collectionView.contentOffset.x = newValue }
            get { return collectionView.contentOffset.x }
        }
    }


