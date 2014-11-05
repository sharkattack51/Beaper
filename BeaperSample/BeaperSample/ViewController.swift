//
//  ViewController.swift
//  BeaperSample
//
//  Created by kasai on 2014/11/05.
//  Copyright (c) 2014年 koichi kasai. All rights reserved.
//

import UIKit

class ViewController: UIViewController, BeaperDelegate {
    
    var beacon:Beaper?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Beacon initialize
        self.beacon = Beaper(
            uuidString: "your_uuid",
            regionIdentifier: "your_region_id",
            notifyOnEntry: false);
        self.beacon!.delegate = self;
        self.beacon!.initBeacon();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Beacon
    
    func foundBeaconImmediate(major: Int, minor: Int, accuracy: Double) {
        NSLog("[ Immediate ] major:\(major) | minor:\(minor) | accuracy:\(accuracy)");
    }
    
    func foundBeaconNear(major: Int, minor: Int, accuracy: Double) {
        NSLog("[ Near ] major:\(major) | minor:\(minor) | accuracy:\(accuracy)");
    }
    
    func foundBeaconFar(major: Int, minor: Int, accuracy: Double) {
        NSLog("[ Far ] major:\(major) | minor:\(minor) | accuracy:\(accuracy)");
    }
}

