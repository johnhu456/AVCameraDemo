//
//  CameraViewController.swift
//  SnapCamera
//
//  Created by MADAO on 16/2/29.
//  Copyright © 2016年 MADAO. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController,UIGestureRecognizerDelegate {
//    enum MyError: ErrorType{
//        case NotExist
//        case Bad
//        case Whaterver
//    }
    
    var beginScale : CGFloat = 1.0
    var endScale : CGFloat = 0.0
    
    var session = AVCaptureSession()
    var input : AVCaptureDeviceInput?
    var output : AVCaptureStillImageOutput?
    var device : AVCaptureDevice?
    var previewLayer = AVCaptureVideoPreviewLayer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        beginScale = 1
        self.setupCamera()
        self.setupFlashButton()
        self.setupGestur()
        // Do any additional setup after loading the view.
    }

    func setupCamera() {
        var error: NSError?
        do {
            input = try AVCaptureDeviceInput(device: self.getBackCamera())
            device = try self.getBackCamera()
        }
        catch let error1 as NSError{
            error = error1
            input = nil
            device = nil
        }
        if error == nil && session.canAddInput(input) {
            session.addInput(input)
            self.setupPreviewLayer()
            self.setupOutput()
        }
//        var newStr : String?
//        var error : NSError?
//        do {
//           newStr = try self.doSomeThingDangerous()
//        }
//        catch MyError.Bad{
//            //Bad
//            newStr = "bad"
//        }
//        catch MyError.NotExist{
//            //
//            newStr = "NotExist"
//        }
//        catch MyError.Whaterver
//        {
//            //
//            newStr = "WhatEver"
//        }
//        catch let error1 as NSError{
//            //
//            error = error1
//            newStr = "error"
//        }
//        if error != nil{
//             print(newStr)
//        }
//
//    }
//    func doSomeThingDangerous() throws -> String{
//        if 1==2 {
//            throw MyError.Bad
//        }
//        else if 2==2 {
//            throw MyError.NotExist
//        }
//        else if 3==4 {
//            throw MyError.Whaterver
//        }
//        else{
//            return "1423424"
//        }
    }
    
    func getCameraWithPostion(postion:AVCaptureDevicePosition) -> AVCaptureDevice? {
        for device in AVCaptureDevice.devices(){
            if device.position == postion{
                return device as? AVCaptureDevice
            }
        }
        return nil
    }
    
    func getBackCamera() throws -> AVCaptureDevice {
        return self.getCameraWithPostion(AVCaptureDevicePosition.Back)!
    }
    
    func setupOutput() {
        output = AVCaptureStillImageOutput()
        output?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        session.addOutput(output)
    }
    
    func setupPreviewLayer() {
        session.sessionPreset = AVCaptureSessionPreset1920x1080
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity =  AVLayerVideoGravityResizeAspectFill
        previewLayer.connection.videoOrientation = AVCaptureVideoOrientation.Portrait;
        previewLayer.frame = self.view.frame
        self.view.layer.addSublayer(previewLayer)
        session.startRunning()
    }
    
    func setupFlashButton() {
        let flashButton = UIButton(type: UIButtonType.Custom)
        flashButton.setTitle("Flash", forState: UIControlState.Normal)
        flashButton.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
        flashButton.frame = CGRectMake(15, 15, 100, 100)
        flashButton.backgroundColor = UIColor.yellowColor()
        flashButton.addTarget(self, action: "setFlashMode", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(flashButton)
    }
    
    func setupGestur() {
        let pinchGR = UIPinchGestureRecognizer(target: self, action: "zoomCamera:")
        pinchGR.delegate = self
        pinchGR.delaysTouchesBegan = true
        self.view.addGestureRecognizer(pinchGR)
    }
    
    //MARK: - Actions
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        let connection = output?.connectionWithMediaType(AVMediaTypeVideo)
        output?.captureStillImageAsynchronouslyFromConnection(connection, completionHandler: { (buffer, error) -> Void in
            let imageData = AVCaptureStillImageOutput .jpegStillImageNSDataRepresentation(buffer)
            let resultImage = UIImage(data: imageData)
            UIImageWriteToSavedPhotosAlbum(resultImage!, nil, nil, nil)
        })
    }
    
    func setFlashMode() {
        if ((device?.torchAvailable) == true){
            var deviceError : NSError?
            do{
                try device?.lockForConfiguration()
            }
            catch let error as NSError
            {
                deviceError = error
                return
            }
            if ((device?.torchActive) == false){
                    if (deviceError == nil){
                    device?.torchMode = AVCaptureTorchMode.On
                }
            }
            else
            {
                device?.torchMode = AVCaptureTorchMode.Off
            }
        }
        device?.unlockForConfiguration()
    }
    
    func zoomCamera(pinchGR: UIPinchGestureRecognizer) {
        var deviceError : NSError?
        let maxScale = output?.connectionWithMediaType(AVMediaTypeVideo).videoMaxScaleAndCropFactor
        endScale = beginScale * pinchGR.scale
        if endScale < 1.0{
            endScale = 1.0
        }
        else if endScale > maxScale {
            endScale = maxScale!
        }
        do{
            try device?.lockForConfiguration()
        }
        catch let error as NSError
        {
            deviceError = error
            return
        }
        if deviceError == nil{
            device?.videoZoomFactor = endScale
            device?.unlockForConfiguration()
        }

        
    }
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        beginScale = endScale
        return true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
