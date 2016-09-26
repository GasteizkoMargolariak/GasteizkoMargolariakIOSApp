//
//  UIViewController.swift
//  Gasteizko Margolariak
//
//  Created by Inigo Valentin on 2016-08-23
//  Copyright © 2016 Inigo Valentin. All rights reserved.
//
//  Based on the work of Yuji Hato.
//

import UIKit

extension UIViewController {
    
    func setNavigationBarItem() {
		self.addLeftBarButtonWithImage(UIImage(named: "ic_menu_black_24dp")!)
		
		let myView: UIView = UIView(frame: CGRectMake(0, 0, 300, 30))
		let title: UILabel = UILabel(frame: CGRectMake(0, 0, 300, 30))
		title.text = "Gasteizko Margolariak"
		title.textColor = UIColor.blackColor()
		title.font = UIFont.boldSystemFontOfSize(20.0)
		title.backgroundColor = UIColor.clearColor()
		let image: UIImage = UIImage(named: "ic_launcher_24dp.png")!
		let myImageView: UIImageView = UIImageView(image: image)
		myImageView.frame = CGRectMake(230, 0, 30, 30)
		myImageView.layer.cornerRadius = 5.0
		myImageView.layer.masksToBounds = true
		myImageView.layer.borderColor = UIColor.lightGrayColor().CGColor
		myImageView.layer.borderWidth = 0.1
		myView.addSubview(title)
		myView.backgroundColor = UIColor.clearColor()
		myView.addSubview(myImageView)
		
		self.navigationItem.titleView = myView
		
		
		self.slideMenuController()?.removeLeftGestures()
        self.slideMenuController()?.addLeftGestures()
    }
    
    func removeNavigationBarItem() {
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItem = nil
        self.slideMenuController()?.removeLeftGestures()
        //self.slideMenuController()?.removeRightGestures()
    }
}
