//
//  Section.swift
//  app
//
//  Created by Iñigo Valentin on 21/11/16.
//  Copyright © 2016 Margolariak. All rights reserved.
//

import Foundation
import UIKit
class Section: UIView {
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var title: UITextView!
    @IBOutlet weak var content: UIView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        Bundle.main.loadNibNamed("Section", owner: self, options: nil)
        self.addSubview(container)
        container.frame = self.bounds
    }
    
    func setTitle(text: String){
        title.text = text
    }
}
