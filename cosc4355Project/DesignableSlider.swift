//
//  DesignableSlider.swift
//  cosc4355Project
//
//  Created by Qaem Parasla
//  Copyright © 2017 cosc4355. All rights reserved.
//

import UIKit

class DesignableSlider: UISlider {
    
    @IBInspectable var thumbImage: UIImage?{
        
        didSet{
            setThumbImage(thumbImage, for: .normal)
        }
    }
}

