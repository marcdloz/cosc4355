//
//  MapSettingViewController.swift
//  cosc4355Project
//
//  Created by Qaem on 12/4/17.
//  Copyright © 2017 cosc4355. All rights reserved.
//

import UIKit

protocol MapSettingDelegate: class {
    func updateMaxTravelDistanceIn(miles: Int)
}

class MapSettingViewController: UIViewController {
    
    
    
    @IBOutlet weak var radiusInMileLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    
    weak var delegate: MapSettingDelegate?
    var radiusInMile: Int = 0
    
    @IBAction func sliderValueChanged(_ sender: UISlider)
    {
        radiusInMileLabel.text = String(round(Double(slider.value))) + " mi"

    }
    
    
    @IBAction func saveMapSetting(_ sender: UIButton)
    {
        if(delegate != nil)
        {
            delegate?.updateMaxTravelDistanceIn(miles: Int(round(slider.value)))
        }
    }
    
    func setSliderValue(value : Float)
    {
        slider.setValue(value, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(Float(radiusInMile) < slider.minimumValue || Float(radiusInMile) > slider.maximumValue)
        {
            let midValue = (slider.maximumValue - slider.maximumValue)/2
            slider.setValue(midValue, animated: true)
        }
        else
        {
            slider.setValue(Float(radiusInMile), animated: true)
            radiusInMileLabel.text = String(round(slider.value))
        }
    }
}
