//
//  ViewController.swift
//  SnapCamera
//
//  Created by MADAO on 16/2/29.
//  Copyright © 2016年 MADAO. All rights reserved.
//

import UIKit
//import CameraViewController

class ViewController: UIViewController {

    var mainScrollView = UIScrollView()
    var leftVC = LeftViewController()
    var cameraVC = CameraViewController()
    var rightVC = RightViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().statusBarHidden = true
        
        mainScrollView = UIScrollView(frame: self.view.frame)
        leftVC = LeftViewController(nibName: "LeftViewController", bundle: nil)
        cameraVC = CameraViewController(nibName: "CameraViewController", bundle:nil)
        rightVC = RightViewController(nibName: "RightViewController", bundle: nil)
        
        self.addChildViewController(leftVC)
        leftVC.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
        mainScrollView.addSubview(leftVC.view)
        leftVC.didMoveToParentViewController(self)
        
        self.addChildViewController(cameraVC)
        mainScrollView.addSubview(cameraVC.view)
        cameraVC.view.frame = CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height)
        cameraVC.didMoveToParentViewController(self)
   
        self.addChildViewController(rightVC)
        mainScrollView.addSubview(rightVC.view)
        rightVC.view.frame = CGRectMake(self.view.frame.size.width * 2, 0, self.view.frame.size.width, self.view.frame.size.height)
        rightVC.didMoveToParentViewController(self)
        
        
        mainScrollView.contentSize = CGSizeMake(self.view.frame.size.width * 3, self.view.frame.size.height)
        mainScrollView.pagingEnabled = true
        self.view.addSubview(mainScrollView);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }

}

