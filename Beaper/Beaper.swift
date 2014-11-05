//
//  Beaper.swift
//
//  Created by koichi kasai on 2014/11/04.
//  Copyright (c) 2014 koichi kasai. All rights reserved.
//

import Foundation
import CoreLocation

@objc protocol BeaperDelegate {
    
    optional func foundBeaconImmediate(major:Int, minor:Int, accuracy:Double);
    optional func foundBeaconNear(major:Int, minor:Int, accuracy:Double);
    optional func foundBeaconFar(major:Int, minor:Int, accuracy:Double);
}

class Beaper: NSObject, CLLocationManagerDelegate {
    
    private var proximityUUID:NSUUID?;
    private var regionIdentifier:String?;
    private var notifyOnEntry:Bool;
    private var locationManager:CLLocationManager?;
    private var beaconRegion:CLBeaconRegion?;
    private var useBeacon:Bool;
    
    var delegate:BeaperDelegate? = nil;
    
    
    init(uuidString:String, regionIdentifier:String, notifyOnEntry:Bool) {
        
        self.proximityUUID = NSUUID(UUIDString: uuidString);
        self.regionIdentifier = regionIdentifier;
        self.notifyOnEntry = notifyOnEntry;
        self.locationManager = CLLocationManager();
        self.beaconRegion = CLBeaconRegion();
        self.useBeacon = false;
        
        super.init();
    }
    
    //ビーコンの初期化
    func initBeacon() {
        
        self.useBeacon = true;
        
        if(CLLocationManager.isMonitoringAvailableForClass(CLCircularRegion)) {
            
            self.locationManager!.delegate = self;
            self.beaconRegion = CLBeaconRegion(proximityUUID: self.proximityUUID, identifier: self.regionIdentifier);
            
            //Background通知設定は入域時のみ。AppDelegate内で行う。
            /*************************************************
            func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
            
                if(launchOptions[UIApplicationLaunchOptionsLocationKey]) {
                    //code
                }
                return true;
            }
            *************************************************/
            self.beaconRegion!.notifyOnEntry = self.notifyOnEntry;
            self.beaconRegion!.notifyOnExit = false;
            self.beaconRegion!.notifyEntryStateOnDisplay = self.notifyOnEntry;
            
            //iOS8対応:Info.plistに項目を追加する [NSLocationAlwaysUsageDescription]
            
            switch CLLocationManager.authorizationStatus() {
                
                case CLAuthorizationStatus.Authorized:
                
                    //ビーコン検出開始
                    self.locationManager!.startMonitoringForRegion(self.beaconRegion);
                    break;
                
                case CLAuthorizationStatus.NotDetermined:
                
                    if (self.locationManager!.respondsToSelector("requestAlwaysAuthorization")) {
                    
                        //ビーコンの使用許可承認
                        self.locationManager!.requestAlwaysAuthorization();
                    }
                    else {
                    
                        //ビーコン検出開始
                        self.locationManager!.startMonitoringForRegion(self.beaconRegion);
                    }
                    break;
                
                default:
                    break;
            }
        }
    }
    
    //ビーコンの使用許可承認
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        if (status == CLAuthorizationStatus.Authorized || status == CLAuthorizationStatus.AuthorizedWhenInUse) {
            
            //ビーコン検出開始
            self.locationManager!.startMonitoringForRegion(self.beaconRegion);
        }
        else
        {
            if(CLLocationManager.locationServicesEnabled()) {
                NSLog("location services not enabled.");
            }
            
            if(CLLocationManager.authorizationStatus() != CLAuthorizationStatus.Authorized) {
                NSLog("location services not authorised.");
            }
        }
    }
    
    //リージョン検出
    func locationManager(manager:CLLocationManager!, didStartMonitoringForRegion region:CLRegion!) {
        
        //リージョンの初期状態確認
        self.locationManager!.requestStateForRegion(region);
    }
    
    //領域に入った
    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        
        if(region.isMemberOfClass(CLBeaconRegion) && CLLocationManager.isRangingAvailable()) {
            
            //レンジ検出開始
            self.locationManager!.startRangingBeaconsInRegion(region as CLBeaconRegion);
        }
    }
    
    //領域から出た
    func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
        
        if(region.isMemberOfClass(CLBeaconRegion) && CLLocationManager.isRangingAvailable()) {
            
            //レンジ検出停止
            self.locationManager!.stopRangingBeaconsInRegion(region as CLBeaconRegion);
        }
    }
    
    //状態確認完了
    func locationManager(manager: CLLocationManager!, didDetermineState state: CLRegionState, forRegion region: CLRegion!) {
        
        switch (state) {
            
        case CLRegionState.Inside:
            if (region.isMemberOfClass(CLBeaconRegion) && CLLocationManager.isRangingAvailable()) {
                
                //既にリージョン範囲内の場合にレンジ検出の開始
                self.locationManager!.startRangingBeaconsInRegion(region as CLBeaconRegion);
            }
            break;
            
        case CLRegionState.Outside:
            break;
            
        case CLRegionState.Unknown:
            break;
            
        default:
            break;
        }
    }
    
    //レンジ検出更新
    func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
        
        if(self.useBeacon && beacons.count > 0) {
            
            //CLProximityUnknown以外のビーコンだけを取り出す
            var validBeacons:NSArray = beacons.filter({ ($0 as CLBeacon).proximity != CLProximity.Unknown });
            var nearestBeacon:CLBeacon = validBeacons[0] as CLBeacon;
            
            //検出処理
            switch (nearestBeacon.proximity) {
                
                //すごく近い 50cm以内
                case CLProximity.Immediate:
                    if let d = self.delegate? {
                        self.delegate!.foundBeaconImmediate?(
                            nearestBeacon.major.integerValue,
                            minor: nearestBeacon.minor.integerValue,
                            accuracy: nearestBeacon.accuracy as Double);
                    }
                    break;
                
                //近い 50cm〜6m
                case CLProximity.Near:
                    if let d = self.delegate? {
                        self.delegate!.foundBeaconNear?(
                            nearestBeacon.major.integerValue,
                            minor: nearestBeacon.minor.integerValue,
                            accuracy: nearestBeacon.accuracy as Double);
                    }
                    break;
                
                //遠い 6m〜20m
                case CLProximity.Far:
                    if let d = self.delegate? {
                        self.delegate!.foundBeaconFar?(
                            nearestBeacon.major.integerValue,
                            minor: nearestBeacon.minor.integerValue,
                            accuracy: nearestBeacon.accuracy as Double);
                    }
                    break;
                
                //見つからない
                case CLProximity.Unknown:
                    break;
                
                default:
                    break;
            }
        }
    }
    
    //検出失敗
    func locationManager(manager: CLLocationManager!, monitoringDidFailForRegion region: CLRegion!, withError error: NSError!) {
        
        NSLog("did fail for region - %@", error.localizedDescription);
    }
    
    //ビーコン反応の停止
    func enableBeacon(state:Bool) {
        
        self.useBeacon = state;
    }
}


