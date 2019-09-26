//
//  CustomImageView.swift
//  cosc4355Project
//
//  Created by Ron Borneo on 10/7/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import Foundation
import UIKit

class CustomImageView: UIImageView {
  static var imageCache = [String: UIImage]()
  
  var lastUrlUsed: String?
   
  func loadImage(url urlString: String) {
    image = nil
    lastUrlUsed = urlString
    /* Checks if the image is already in the cache. If so, just set it. */
    if let cachedImage = CustomImageView.imageCache[urlString] {
      image = cachedImage
      return
    }
    
    /* Validates proper URL format */
    guard let url = URL(string: urlString) else { return }
    
    URLSession.shared.dataTask(with: url) { (data, response, error) in
      if let error = error {
        print("Error Occured: \(error)")
        return
      }
      /* I don't understand why this is here... wouldn't this always be true? */
      if url.absoluteString != self.lastUrlUsed { return }
      
      /* Checks if data was downloaded properly */
      guard let imageData = data else { return }
      
      /* Construct image based on downloaded data */
      let photoImage = UIImage(data: imageData)
      
      CustomImageView.imageCache[url.absoluteString] = photoImage
      
      /* GCD, multithreaded solution. Async = nonblocking */
      DispatchQueue.main.async {
        self.image = photoImage
        print("testphoto")
      }
    }.resume()
  }
    
    
}
