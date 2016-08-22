//
//  DataTableViewCell.swift
//  Gasteizko Margolariak
//
//  Created by Inigo Valentin on 2016-08-23
//  Copyright © 2016 Inigo Valentin. All rights reserved.
//
//  Based on the work of Yuji Hato.
//

import UIKit

struct DataTableViewCellData {
    
    init(imageUrl: String, text: String) {
        self.imageUrl = imageUrl
        self.text = text
    }
    var imageUrl: String
    var text: String
}

class DataTableViewCell : BaseTableViewCell {
    
    @IBOutlet weak var dataImage: UIImageView!
    @IBOutlet weak var dataText: UILabel!
    
    override func awakeFromNib() {
        self.dataText?.font = UIFont.italicSystemFontOfSize(16)
        self.dataText?.textColor = UIColor(hex: "9E9E9E")
    }
 
    override class func height() -> CGFloat {
        return 80
    }
    
    override func setData(data: Any?) {
        if let data = data as? DataTableViewCellData {
            self.dataImage.setRandomDownloadImage(80, height: 80)
            self.dataText.text = data.text
        }
    }
}
