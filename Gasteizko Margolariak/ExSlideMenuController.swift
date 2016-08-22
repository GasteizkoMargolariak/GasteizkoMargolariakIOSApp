//
//  ExSlideMenuController.swift
//  Gasteizko Margolariak
//
//  Created by Inigo Valentin on 2016-08-23
//  Copyright © 2016 Inigo Valentin. All rights reserved.
//
//  Based on the work of Yuji Hato.
//

import UIKit

class ExSlideMenuController : SlideMenuController {

    override func isTagetViewController() -> Bool {
        if let vc = UIApplication.topViewController() {
            if vc is MainViewController ||
            vc is HomeViewController ||
            vc is LocationViewController ||
            vc is LablancaViewController ||
            vc is ScheduleViewController ||
            vc is GmscheduleViewController ||
            vc is ActivitiesViewController ||
            vc is BlogViewController ||
            vc is GalleryViewController ||
            vc is SettingsViewController {
                return true
            }
        }
        return false
    }
}
