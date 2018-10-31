//
//  GalleryTableViewCell.swift
//  My Little Shudder
//
//  Created by Sergey Timoshpolskiy on 30/10/2018.
//  Copyright © 2018 Sergey Timoshpolskii. All rights reserved.
//

import UIKit

class GalleryTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
