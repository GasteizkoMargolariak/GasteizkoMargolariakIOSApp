//
//  GalleryViewController.swift
//  Gasteizko Margolariak
//
//  Created by Inigo Valentin on 22/08/16.
//  Copyright © 2016 Gasteizko Margolariak. All rights reserved.
//

import UIKit

class GalleryViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarItem()
    }
}