//
//  ShudderTableViewController.swift
//  My Little Shudder
//
//  Created by Sergey Timoshpolskiy on 30/10/2018.
//  Copyright © 2018 Sergey Timoshpolskii. All rights reserved.
//

import UIKit

class ShudderTableViewController: UITableViewController, UICollectionViewDelegate, UICollectionViewDataSource, ShudderModelDelegate {

    // Model handle
    var shudderModel = ShudderModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // setup tableView outlook
        tableView.rowHeight = 180
        tableView.contentInset = UIEdgeInsets(top: -28, left: 0, bottom: 0, right: 0)
        
        // Set self as a Model delegate
        shudderModel.delegate = self
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return shudderModel.galleryTitles.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // section 0 is a "Hero" section, it has no title
        return section == 0 ? "" : shudderModel.galleryTitles[section]
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // section 0 is a "Hero" section, it has no header
        return section == 0 ? 0 : 28
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let headerView = view as? UITableViewHeaderFooterView else { return }
        headerView.textLabel?.textColor = UIColor.lightGray
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        var collectionView : UICollectionView?
        
        if indexPath.section == 0 {
            // Setup "Hero" carousel tableView cell
            cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cells.heroTableViewCell, for: indexPath)
            if let heroTVCell = cell as? HeroTableViewCell {
                collectionView = heroTVCell.collectionView
            }
        } else {
            // Setup regular carousel tableView cell
            cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cells.galleryTableViewCell, for: indexPath)
            
            if let galleryTVCell = cell as? GalleryTableViewCell {
                collectionView = galleryTVCell.collectionView
            }
        }
        
        // Tag this cells collectionView to distinguish them in the delegate later
        collectionView?.tag = indexPath.section
        
        // Setup collectionView dataSource and delegate
        collectionView?.dataSource = self
        collectionView?.delegate = self
        
        collectionView?.reloadData()
        
        return cell
    }
    
    // MARK: - Collection View data source
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return shudderModel.imageURLs[collectionView.tag].count

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.Cells.imageCollectionViewCell, for: indexPath)
        
        guard let imageCVCell = cell as? ImageCollectionViewCell else { return cell }
        
        imageCVCell.imageURL = shudderModel.imageURLs[collectionView.tag][indexPath.row]
        
        return cell
        
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updatePositionIfNeeded(forScrollView: scrollView)
        
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        updatePositionIfNeeded(forScrollView: scrollView)
    }
    
    /*
     Checks if a scrollView is the "Hero" collectionView
     If it is, checks its scrolling positiong
     Updates scrolling offset so that scrolling would seem circular
     */
    private func updatePositionIfNeeded(forScrollView scrollView: UIScrollView) {
        // Only collectionView with a tag 0 is of interest here
        if scrollView.tag == 0, let collectionView = scrollView as? UICollectionView {
            if collectionView.contentOffset.x == 0 {
                // Scrolling left
                let lastButOneIndexPath = IndexPath(row: shudderModel.imageURLs[0].count-2, section: 0)
                collectionView.scrollToItem(at: lastButOneIndexPath, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: false)
                
            } else if collectionView.contentOffset.x == collectionView.contentSize.width - collectionView.frame.size.width {
                //scrolling right
                let secondIndexPath = IndexPath(row: 1, section: 0)
                collectionView.scrollToItem(at: secondIndexPath, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: false)
                
            }
        }
    }
    
    // MARK: - Model delegate methods
    
    func didRecieveGalleryTitles() {
        DispatchQueue.main.async { [unowned self] in
            self.tableView.reloadData()
        }
    }
    
    func didRecieveImageUrl(forGalleryAt index: Int) {
        DispatchQueue.main.async { [unowned self] in
            let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: index))
            if index == 0,
                self.shudderModel.imageURLs[0].count > 1,
                let heroCell = cell as? HeroTableViewCell {

                heroCell.collectionView.reloadData()
                
                // for "Hero" collectionView scroll to the second element, so that there would be an element to the left of the first showed one
                heroCell.collectionView.scrollToItem(at: IndexPath(row: 1, section: 0),
                                                     at: .centeredHorizontally,
                                                     animated: false)
            }
            if index != 0, let galleryCell = cell as? GalleryTableViewCell {
                galleryCell.collectionView.reloadData()
            }
        }
    }

}
