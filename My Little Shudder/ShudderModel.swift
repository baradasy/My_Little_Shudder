//
//  ShudderModel.swift
//  My Little Shudder
//
//  Created by Sergey Timoshpolskiy on 30/10/2018.
//  Copyright © 2018 Sergey Timoshpolskii. All rights reserved.
//

import Foundation

class ShudderModel {

    // Images URLs and Gallery titles - the actual model data
    var imageURLs = [[URL]]()
    var galleryTitles = [String]()
    
    // model delegate handle
    weak var delegate : ShudderModelDelegate?
    
    // Private model data
    // flickr Gallery IDs
    private var galleryIDs = [String]()
    
    // flickr API key
    private let flickrKey = "90c4d84a8ff3fc5026ed883258238b57"
    
    // flickr userID - this users galleries are shown as image data
    private let flickrUserID = "144903836@N02"
    
    init() {
        // fetch Flickr gallery titles and their content
        fetchGalleryTitles()
    }
    
    // fetches flickr Gallery titles for specified user
    private func fetchGalleryTitles() {
        
        // Initialize session and URL
        let session = URLSession.shared
        let urlString = "https://api.flickr.com/services/rest?method=flickr.galleries.getList&continuation=0&format=json&nojsoncallback=1&api_key=\(flickrKey)&user_id=\(flickrUserID)"
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
        
        // Initialize task
        let task = session.dataTask(with: request) {[unowned self] data, response, downloadError in
            if let error = downloadError {
                print("Could not complete the request \(error)")
            } else {
                
                // Parse request data
                let parsedResult = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                
                guard let galleriesDictionary = (parsedResult as AnyObject).value(forKey: "galleries") as? NSDictionary else {
                    print("Couldn't find 'galleries' key in \(parsedResult)")
                    return
                }
                
                guard let galleryArray = galleriesDictionary.value(forKey: "gallery") as? [[String: AnyObject]] else {
                    print("Couldn't find 'gallery' key in \(galleriesDictionary)")
                    return
                }
                
                // For each flickr gallery
                for galleryDict in galleryArray {
                    guard let titleDict = galleryDict["title"] as? [String:String],
                        let title = titleDict["_content"] else {
                        print("Couldn't find 'title' key in \(galleryDict)")
                        return
                    }
                    
                    guard let id = galleryDict["id"] as? String else {
                        print("Couldn't find 'id' key in \(galleryDict)")
                        return
                    }
                    
                    // Update ShudderModel data
                    self.galleryTitles.append(title)
                    self.galleryIDs.append(id)
                    self.imageURLs.append([])
                    
                    // Fetch image URLs
                    self.fetchImageURLs(forGalleryAt: self.galleryTitles.count-1)
                    
                    // Let the delegate know model was updated
                    self.delegate?.didRecieveGalleryTitles()

                }
                
            }
        }
        
        task.resume()
    }
    
    // fetches the URLs of the images for each gallery
    private func fetchImageURLs(forGalleryAt index: Int) {
        let galleryID = galleryIDs[index]
        
        // Initialize session and URL
        let session = URLSession.shared
        let urlString = "https://api.flickr.com/services/rest?method=flickr.galleries.getPhotos&extras=url_m&&format=json&nojsoncallback=1&api_key=\(flickrKey)&gallery_id=\(galleryID)"
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
        
        // Initialize task
        let task = session.dataTask(with: request) {[unowned self] data, response, downloadError in
            if let error = downloadError {
                print("Could not complete the request \(error)")
            } else {
                
                // Parse request data
                let parsedResult = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                
                guard let photosDictionary = (parsedResult as AnyObject).value(forKey: "photos") as? NSDictionary else {
                    print("Couldn't find 'photos' key in \(parsedResult)")
                    return
                }
                
                guard let photoArray = photosDictionary.value(forKey: "photo") as? [[String: AnyObject]] else {
                    print("Couldn't find 'photo' key in \(photosDictionary)")
                    return
                }
                
                // For each flickr gallery
                for photoDict in photoArray {
                    guard let imageUrlString = photoDict["url_m"] as? String else {
                        print("Couldn't find 'url_m' key in \(photoDict)")
                        return
                    }
                    
                    guard let imageURL = URL(string: imageUrlString) else {
                        print("Couldn't convert URLstring to URL")
                        return
                    }
                    
                    // Update ShudderModel data
                    self.imageURLs[index].append(imageURL)
                    
                    // Let the delegate know model updated
                    self.delegate?.didRecieveImageUrl(forGalleryAt: index)
                    
                }
                
                // for "Hero" gallery add first element to the end and last element to begining to emulate circular rotation
                if index == 0,
                    let firstURL = self.imageURLs[index].first,
                    let lastURL = self.imageURLs[index].last {
                    
                    self.imageURLs[index].insert(lastURL, at: 0)
                    self.imageURLs[index].append(firstURL)
                    
                }
            }
        }
        
        task.resume()
    }
    
}

protocol ShudderModelDelegate: class {
    func didRecieveGalleryTitles()
    func didRecieveImageUrl(forGalleryAt index: Int)
}
