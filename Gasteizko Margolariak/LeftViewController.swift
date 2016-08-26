//
//  LeftViewController.swift
//  Gasteizko Margolariak
//
//  Created by Inigo Valentin on 2016-08-23
//  Copyright © 2016 Inigo Valentin. All rights reserved.
//
//  Based on the work of Yuji Hato.
//

import UIKit

enum LeftMenu: Int {
    case Home = 0
    case Location
    case Lablanca
    case Schedule
    case Gmschedule
    case Activities
    case Blog
    case Gallery
    case Settings
}

protocol LeftMenuProtocol : class {
    func changeViewController(menu: LeftMenu)
}

class LeftViewController : UIViewController, LeftMenuProtocol {
    
    @IBOutlet weak var tableView: UITableView!
    var menus = ["Home", "Localizacion", "La Blanca", "Programa de Fiestas", "Programa Margolari", "Actividades", "Blog", "Galeria", "Ajustes"]
    var homeViewController: UIViewController!
    var locationViewController: UIViewController!
    var lablancaViewController: UIViewController!
    var scheduleViewController: UIViewController!
    var gmscheduleViewController: UIViewController!
    var activitiesViewController: UIViewController!
    var blogViewController: UIViewController!
    var galleryViewController: UIViewController!
    var settingsViewController: UIViewController!
    
   // var imageHeaderView: ImageHeaderView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.tableView.separatorColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let homeViewController = storyboard.instantiateViewControllerWithIdentifier("HomeViewController") as! HomeViewController
        self.homeViewController = UINavigationController(rootViewController: homeViewController)
        
        let locationViewController = storyboard.instantiateViewControllerWithIdentifier("LocationViewController") as! LocationViewController
        self.locationViewController = UINavigationController(rootViewController: locationViewController)
		
		let lablancaViewController = storyboard.instantiateViewControllerWithIdentifier("LablancaViewController") as! LablancaViewController
		self.lablancaViewController = UINavigationController(rootViewController: lablancaViewController)
		
		let scheduleViewController = storyboard.instantiateViewControllerWithIdentifier("ScheduleViewController") as! ScheduleViewController
		self.scheduleViewController = UINavigationController(rootViewController: scheduleViewController)
		
		let gmscheduleViewController = storyboard.instantiateViewControllerWithIdentifier("GmscheduleViewController") as! GmscheduleViewController
		self.gmscheduleViewController = UINavigationController(rootViewController: gmscheduleViewController)
		
		let activitiesViewController = storyboard.instantiateViewControllerWithIdentifier("ActivitiesViewController") as! ActivitiesViewController
		self.activitiesViewController = UINavigationController(rootViewController: activitiesViewController)
		
		let blogViewController = storyboard.instantiateViewControllerWithIdentifier("BlogViewController") as! BlogViewController
		self.blogViewController = UINavigationController(rootViewController: blogViewController)
		
		let galleryViewController = storyboard.instantiateViewControllerWithIdentifier("GalleryViewController") as! GalleryViewController
		self.galleryViewController = UINavigationController(rootViewController: galleryViewController)
		
		let settingsViewController = storyboard.instantiateViewControllerWithIdentifier("SettingsViewController") as! SettingsViewController
		self.settingsViewController = UINavigationController(rootViewController: settingsViewController)
		
        self.tableView.registerCellClass(BaseTableViewCell.self)
        
        //self.imageHeaderView = ImageHeaderView.loadNib()
        //self.view.addSubview(self.imageHeaderView)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //self.imageHeaderView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 160)
        self.view.layoutIfNeeded()
    }
    
    func changeViewController(menu: LeftMenu) {
		print("Selected item: \(menu)")
        switch menu {
			case .Home:
				self.slideMenuController()?.changeMainViewController(self.homeViewController, close: true)
			case .Location:
				self.slideMenuController()?.changeMainViewController(self.locationViewController, close: true)
			case .Lablanca:
				self.slideMenuController()?.changeMainViewController(self.lablancaViewController, close: true)
			case .Schedule:
				self.slideMenuController()?.changeMainViewController(self.scheduleViewController, close: true)
			case .Gmschedule:
				self.slideMenuController()?.changeMainViewController(self.gmscheduleViewController, close: true)
			case .Activities:
				self.slideMenuController()?.changeMainViewController(self.activitiesViewController, close: true)
			case .Blog:
				self.slideMenuController()?.changeMainViewController(self.blogViewController, close: true)
			case .Gallery:
				self.slideMenuController()?.changeMainViewController(self.galleryViewController, close: true)
			case .Settings:
				self.slideMenuController()?.changeMainViewController(self.settingsViewController, close: true)
        }
    }
}

extension LeftViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let menu = LeftMenu(rawValue: indexPath.item) {
            switch menu {
            case .Home, .Location, .Lablanca, .Schedule, .Gmschedule, .Activities, .Blog, .Gallery, .Settings:
                return BaseTableViewCell.height()
            }
        }
        return 0
    }
}

extension LeftViewController : UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let menu = LeftMenu(rawValue: indexPath.item) {
            switch menu {
            case .Home, .Location, .Lablanca, .Schedule, .Gmschedule, .Activities, .Blog, .Gallery, .Settings:
                let cell = BaseTableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: BaseTableViewCell.identifier)
                cell.setData(menus[indexPath.row])
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let menu = LeftMenu(rawValue: indexPath.item) {
            self.changeViewController(menu)
        }
    }
}

extension LeftViewController: UIScrollViewDelegate {
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if self.tableView == scrollView {
            
        }
    }
}
