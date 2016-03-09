//
// Copyright 2016 ESRI
//
// All rights reserved under the copyright laws of the United States
// and applicable international laws, treaties, and conventions.
//
// You may freely redistribute and use this sample code, with or
// without modification, provided you include the original copyright
// notice and use restrictions.
//
// See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
//

import UIKit
import ArcGIS

extension AGSJobStatus {
    var asString: String {
        switch self.rawValue {
        case 0: return "NotStarted"
        case 1: return "Starting"
        case 2: return "Started"
        case 3: return "FetchingResult"
        case 4: return "Paused"
        case 5: return "Done"
        default: return "Unknown..."
        }
    }
}

var documentDirectory: String { return NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask,true)[0] }

class ViewController: UIViewController {
    
    @IBOutlet weak var mapView:AGSMapView!
    @IBOutlet weak var downloadPanel:UIView!
    @IBOutlet weak var scaleLabel:UILabel!
    @IBOutlet weak var estimateLabel:UILabel!
    @IBOutlet weak var lodLabel:UILabel!
    @IBOutlet weak var estimateButton:UIButton!
    @IBOutlet weak var downloadButton:UIButton!
    @IBOutlet weak var levelStepper:UIStepper!
    @IBOutlet weak var timerLabel:UILabel!
    
    var tileCacheTask: AGSExportTileCacheTask!
    var tiledLayer: AGSArcGISTiledLayer!
    var exportJob: AGSJob!
    
    // in iOS7 this gets called and hides the status bar so the view does not go under the top iPhone status bar
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //You can change this to any other service on tiledbasemaps.arcgis.com if you have an ArcGIS for Organizations subscription
        let tileServiceURL = "http://sampleserver6.arcgisonline.com/arcgis/rest/services/World_Street_Map/MapServer"
        
        //Add basemap layer to the map
        //Set delegate to be notified of success or failure while loading
        let tiledUrl = NSURL(string: tileServiceURL)
        self.tiledLayer = AGSArcGISTiledLayer(URL: tiledUrl!)
        self.tiledLayer.loadWithCompletion { (error) -> Void in
            if error == nil {
                self.levelStepper.value = 0
                self.levelStepper.minimumValue = 0
                self.levelStepper.maximumValue = Double(self.tiledLayer.tileInfo!.levelsOfDetail.count-1)
            }
        }
        
        let map = AGSMap()
        map.basemap?.baseLayers.addObject(self.tiledLayer)
        
        self.scaleLabel.numberOfLines = 0
        
        self.mapView.map = map
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func currentLOD() -> AGSLevelOfDetail! {
        if let tl = self.tiledLayer {
            if let ti = tl.tileInfo {
                for lod in ti.levelsOfDetail {
                    if lod.scale >= self.mapView.mapScale {
                        return lod
                    }
                }
            }
        }
        return nil
    }
    
    @IBAction func changeLevels(sender: AnyObject) {
        //Enable buttons because the user has specified how many levels to download
        self.estimateButton.enabled = true
        self.downloadButton.enabled = true
        self.levelStepper.minimumValue = 1
        
        //Display the levels
        self.lodLabel.text = "\(Int(self.levelStepper.value))"
        
        //Display the scale range that will be downloaded based on specified levels
        let currentScale = "\(Int(currentLOD().scale))"
        let maxLOD = self.tiledLayer.tileInfo?.levelsOfDetail[Int(self.levelStepper.value)]
        let maxScale = "\(Int(maxLOD!.scale))"
        self.scaleLabel.text = String(format: "1:%@\n\tto\n1:%@",currentScale , maxScale)
    }

    @IBAction func estimateAction(sender: AnyObject) {
        if self.tileCacheTask == nil {
            self.tileCacheTask = AGSExportTileCacheTask(mapServiceInfo: self.tiledLayer.mapServiceInfo!)
        }
        
        //Prepare list of levels to download
        let desiredLevels = self.levelsWithCount(Int(self.levelStepper.value), startingAt:0, fromLODs: self.tiledLayer.tileInfo?.levelsOfDetail)
        print("LODs requested \(desiredLevels)")
        
        //Use current envelope to download
        let extent = self.mapView.visibleArea?.extent
        
        //Prepare params with levels and envelope
        let params = AGSExportTileCacheParameters()
        params.levelsOfDetail = desiredLevels
        params.areaOfInterest = extent
        
        //kick-off operation to estimate size
        self.tileCacheTask.mapServiceInfo.loadWithCompletion { (error) -> Void in
            if error != nil {
                print("Task load errro: \(error)")
            } else {
                self.exportJob = self.tileCacheTask.estimateTileCacheSizeJobWithParameters(params)
                self.exportJob.startWithStatusHandler({ (status) -> Void in
                    print("Job status: \(status.asString)")
                    print("Message: \(self.exportJob.messages.last?.message)")
                    }) { (result, error) -> Void in
                        if let result = result {
                            print("job succeeded: \(result)")
                            if let estimate = result as? AGSExportTileCacheSizeEstimate {
                                //Display results (# of bytes and tiles), properly formatted, ofcourse
                                let tileCountString = "\(estimate.tileCount)"
                                
                                let byteCountFormatter = NSByteCountFormatter()
                                let byteCountString = byteCountFormatter.stringFromByteCount( Int64(estimate.fileSize) )
                                
                                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                                    dispatch_async(dispatch_get_main_queue()) {
                                        self.estimateLabel.text = "\(byteCountString) / \(tileCountString) tiles"
                                        SVProgressHUD.showSuccessWithStatus("Estimated size:\n\(byteCountString) / \(tileCountString) tiles")
                                    }
                                }
                            }
                        }
                        else if let error = error{
                            print("job failed: \(error)")
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                                dispatch_async(dispatch_get_main_queue()) {
                                    UIAlertView(title: "Error", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "Ok").show()
                                    SVProgressHUD.dismiss()
                                }
                            }
                        }
                }
            }
        }
        
        SVProgressHUD.showWithStatus("Estimating\n size", maskType:4)
    }

    @IBAction func downloadAction(sender: AnyObject) {
        if self.tileCacheTask == nil {
            self.tileCacheTask = AGSExportTileCacheTask(mapServiceInfo: self.tiledLayer.mapServiceInfo!)
        }
        //Prepare list of levels to download
        let desiredLevels = self.levelsWithCount(Int(self.levelStepper.value), startingAt:0, fromLODs:self.tiledLayer.tileInfo?.levelsOfDetail)
        print("LODs requested \(desiredLevels)")
        
        //Use current envelope to download
        let extent = self.mapView.visibleArea?.extent
        
        //Prepare params using levels and envelope
        let params = AGSExportTileCacheParameters()
        params.levelsOfDetail = desiredLevels
        params.areaOfInterest = extent
        
        //Kick-off operation
        self.tileCacheTask.mapServiceInfo.loadWithCompletion { (error) -> Void in
            if error != nil {
                print("Task load errro: \(error)")
            } else {
                self.exportJob = self.tileCacheTask.exportTileCacheJobWithParameters(params, downloadFilePath: "\(documentDirectory)/testDownload.tpk")
                self.exportJob.startWithStatusHandler({ (status) -> Void in
                    print("\(status.asString)")
                    
                    if let message = self.exportJob.messages.last?.message {
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                            dispatch_async(dispatch_get_main_queue()) {
                                SVProgressHUD.showWithStatus(message, maskType:4)
                            }
                        }
                    }
                }) { (result, error) -> Void in
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                        dispatch_async(dispatch_get_main_queue()) {
                            SVProgressHUD.dismiss()
                        }
                    }
                    if error != nil {
                        //alert the user
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                            dispatch_async(dispatch_get_main_queue()) {
                                UIAlertView(title: "Error", message: error!.localizedDescription, delegate: nil, cancelButtonTitle: "Ok").show()
                                self.estimateLabel.text = ""
                            }
                        }
                    }
                    else{
                        
                        if let result = result as? AGSTileCache {
                            let LTC = AGSArcGISTiledLayer(tileCache: result)
                            self.mapView.map!.basemap?.baseLayers.removeAllObjects()
                            self.mapView.map!.basemap?.baseLayers.addObject(LTC)
                            
                            //Tell the user we're done
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                                dispatch_async(dispatch_get_main_queue()) {
                                    UIAlertView(title: "Download Complete", message: "The tile cache has been added to the map", delegate: nil, cancelButtonTitle: "Ok").show()
                                }
                            }
                        }
                    }
                }
            }
        }   

        SVProgressHUD.showWithStatus("Preparing\n to download", maskType: 4)
    }
    
    func levelsWithCount(count:Int, startingAt startLOD:Int, fromLODs allLODs:[AGSLevelOfDetail]?) -> [Int] {
        return allLODs![startLOD..<(startLOD + count)].map{ $0.level }
    }
}