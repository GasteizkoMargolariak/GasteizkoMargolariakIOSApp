//
//  HomeView.swift
//  app
//
//  Created by Iñigo Valentin on 21/11/16.
//  Copyright © 2016 Margolariak. All rights reserved.
//

import Foundation
import UIKit
class HomeView: UIView {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var locationSection: Section!
    @IBOutlet weak var lablancaSection: Section!
    @IBOutlet weak var futureActivitiesSection: Section!
    @IBOutlet weak var blogSection: Section!
    @IBOutlet weak var gallerySection: Section!
    @IBOutlet weak var pastActivitiesSection: Section!
    @IBOutlet weak var socialSection: Section!
    
    required init?(coder aDecoder: NSCoder) {
        
        print("HomeView: init")
        super.init(coder: aDecoder)
        
        Bundle.main.loadNibNamed("HomeView", owner: self, options: nil)
        self.addSubview(container)
        container.frame = self.bounds
        
        
        
        //Set titles
        locationSection.setTitle(text: "Encuentranos")
        lablancaSection.setTitle(text: "La Blanca")
        futureActivitiesSection.setTitle(text: "Proximas actividades")
        blogSection.setTitle(text: "Ultimos posts")
        gallerySection.setTitle(text: "Ultimas fotos")
        pastActivitiesSection.setTitle(text: "Ultimas actividades")
        socialSection.setTitle(text: "Siguenos")
        
        //Always at the end: update scrollview
        //var contentRect: CGRect = CGRect.zero;
        //for view in scrollView.subviews {
        //    contentRect = contentRect.union(view.frame);
        //}
        //self.scrollView.contentSize = contentRect.size;
        
        
        var h: Int = 0
        for view in scrollView.subviews {
            //contentRect = contentRect.union(view.frame);
            h = h + Int(view.frame.height) + 30 //Why 30?
            print("curh: \(h)")
        }
        self.scrollView.contentSize.height = CGFloat(h);
        
        //let lastView : Section! = scrollView.subviews.last as! Section!
        //let height = lastView.frame.size.height
        //let pos = lastView.frame.origin.y
        //let sizeOfContent = height + pos + 10
        //scrollView.contentSize.height = sizeOfContent
    }
}
