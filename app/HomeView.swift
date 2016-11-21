// Copyright (C) 2016 Inigo Valentin
//
// This file is part of the Gasteizko Margolariak IOS app.
//
// The Gasteizko Margolariak IOS app is free software: you can
// redistribute it and/or modify it under the terms of the
// GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your
// option) any later version.
//
// The Gasteizko Margolariak IOS app is distributed in the
// hope that it will be useful, but WITHOUT ANY WARRANTY;
// without even the implied warranty of MERCHANTABILITY or
// FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
// Public License for more details.
//
// You should have received a copy of the GNU General Public
// License along with the Gasteizko Margolariak IOS app.
// If not, see <http://www.gnu.org/licenses/>.

import Foundation
import UIKit

/**
 Class to handle the home view.
 */
class HomeView: UIView {
    
    //The main scroll view.
    @IBOutlet weak var scrollView: UIScrollView!
    
    //The container of the view.
    @IBOutlet weak var container: UIView!
    
    //Each of the sections of the view.
    @IBOutlet weak var locationSection: Section!
    @IBOutlet weak var lablancaSection: Section!
    @IBOutlet weak var futureActivitiesSection: Section!
    @IBOutlet weak var blogSection: Section!
    @IBOutlet weak var gallerySection: Section!
    @IBOutlet weak var pastActivitiesSection: Section!
    @IBOutlet weak var socialSection: Section!
    
    /**
     Run when the view is started.
    */
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        //Load the contents of the HomeView.xib file.
        Bundle.main.loadNibNamed("HomeView", owner: self, options: nil)
        self.addSubview(container)
        container.frame = self.bounds
        
        //Set titles for each section
        locationSection.setTitle(text: "Encuentranos")
        lablancaSection.setTitle(text: "La Blanca")
        futureActivitiesSection.setTitle(text: "Proximas actividades")
        blogSection.setTitle(text: "Ultimos posts")
        gallerySection.setTitle(text: "Ultimas fotos")
        pastActivitiesSection.setTitle(text: "Ultimas actividades")
        socialSection.setTitle(text: "Siguenos")
        
        //Always at the end: update scrollview
        var h: Int = 0
        for view in scrollView.subviews {
            //contentRect = contentRect.union(view.frame);
            h = h + Int(view.frame.height) + 30 //Why 30?
            print("curh: \(h)")
        }
        self.scrollView.contentSize.height = CGFloat(h);
    }
}
