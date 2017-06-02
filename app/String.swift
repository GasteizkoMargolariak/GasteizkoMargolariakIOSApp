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
Extension of String to include custom utilities.
*/
extension String {
	
	
	/**
	The length of the string.
	*/
	var length:Int {
		return self.characters.count
	}
	
	
	/**
	Finds the first position of a substring.
	:param: target The substring to look for.
	:return: The index of the first occurrence of the substring.
	*/
	func indexOf(target: String) -> Int? {
		
		let range = (self as NSString).range(of: target)
		
		guard range.toRange() != nil else {
			return nil
		}
		
		return range.location
		
	}
	
	
	/**
	Finds the last position of a substring.
	:param: target The substring to look for.
	:return: The index of the las ocurrence of the substring.
	*/
	func lastIndexOf(target: String) -> Int? {
		
		
		
		let range = (self as NSString).range(of: target, options: NSString.CompareOptions.backwards)
		
		guard range.toRange() != nil else {
			return nil
		}
		
		return self.length - range.location - 1
		
	}
	
	
	/**
	Checks for a substring
	:param: target Ths substring to look for.
	:return: True if the substring is contained in the string, false otherwise.
	*/
	func contains(s: String) -> Bool {
		return (self.range(of: s) != nil) ? true : false
	}
	
	
	/**
	Gets a subset of the string.
	:param: start The beggining index of the substring.
	:param: start The ending index of the substring.
	:return: The substring.
	*/
	func subStr(start: Int, end: Int) -> String{
		
		let st = self.index(self.startIndex, offsetBy: start)
		let ed = self.index(self.startIndex, offsetBy: end)
		
		let range = st...ed
		return self[range]
	}
	
	
	/**
	Removes HTML symbolf from the string. It also decodes HTML symbols.
	:return: The string eithout the HTML symbols.
	*/
	func stripHtml() -> String {
		let d = data(using: String.Encoding.utf8)
		do{
			return try NSAttributedString(data: d!, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue], documentAttributes: nil).string
		} catch let error as NSError {
			print(error.localizedDescription)
			return self
		}
	}
	
	
	/**
	Removes escaped characters and unicode symbols from the string.
	:return: Escaped string.
	*/
	func decode() -> String {
		
		let transform: NSString = "Any-Hex/Java"
		let convertedString: NSMutableString = (self as NSString).mutableCopy() as! NSMutableString
		
		CFStringTransform(convertedString, nil, transform, true)
		return (convertedString as String).replacingOccurrences(of: "\\/", with: "/")
	}
}
