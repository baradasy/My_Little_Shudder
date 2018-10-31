//
//  ImageCollectionViewCell.swift
//  My Little Shudder
//
//  Created by Sergey Timoshpolskiy on 30/10/2018.
//  Copyright © 2018 Sergey Timoshpolskii. All rights reserved.
//

import UIKit
import SDWebImage

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var image: UIImageView!
    
    public var imageURL: URL? { didSet { updateUI() } }
    
    private func updateUI() {
    
        image.sd_setImage(with: imageURL)
        
        image.layer.masksToBounds = true
        image.layer.cornerRadius = 4
        
    }
    
    
}
