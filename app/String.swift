//
//  String.swift
//  app
//
//  Created by Iñigo Valentin on 2/1/17.
//  Copyright © 2017 Margolariak. All rights reserved.
//

import Foundation

extension String {
    var length:Int {
        return self.characters.count
    }
    
    func indexOf(target: String) -> Int? {
        
        let range = (self as NSString).range(of: target)
        
        guard range.toRange() != nil else {
            return nil
        }
        
        return range.location
        
    }
    func lastIndexOf(target: String) -> Int? {
        
        
        
        let range = (self as NSString).range(of: target, options: NSString.CompareOptions.backwards)
        
        guard range.toRange() != nil else {
            return nil
        }
        
        return self.length - range.location - 1
        
    }
    func contains(s: String) -> Bool {
        return (self.range(of: s) != nil) ? true : false
    }
    
    func subStr(start: Int, end: Int) -> String{
        
        let st = self.index(self.startIndex, offsetBy: start)
        var ed = self.index(self.startIndex, offsetBy: end)
        
        let range = st...ed
        return self[range]
    }
}
