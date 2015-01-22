Beaper
======
Simple wrapper library of iBeacon for Swift.

### Example

create an instance.

```Swift
//Initialize
self.beacon = Beaper(uuidString: "your_uuid", regionIdentifier: "your_region_id",notifyOnEntry: false);
self.beacon!.delegate = self;
self.beacon!.initBeacon();
```

and implements the `BeaperDelegate` protocol.

```Swift
//Delegate
func foundBeaconImmediate(major: Int, minor: Int, accuracy: Double) {}
func foundBeaconNear(major: Int, minor: Int, accuracy: Double) {}
func foundBeaconFar(major: Int, minor: Int, accuracy: Double) {}
```

add a `NSLocationAlwaysUsageDescription` key to Info.plist. 
