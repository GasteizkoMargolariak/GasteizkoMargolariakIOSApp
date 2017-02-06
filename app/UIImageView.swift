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
Extension of UIImageView to include custom utilities.
*/
extension UIImageView {
	
	/**
	Sets an image in the UIImageView. If the image is downloaded, it will not download it again.
	If it isn't, it will download it.
	:param: localPath Path where the image is or will be.
	:param: remotePath Url of the image to download (if not cached).
	:return: 0 if the file was set form the local path, 1 if the file was downloaded, other for error.
	*/
	func setImage(localPath: String, remotePath: String) -> Int{
		//Check if the local image exists.
		let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
		let url = NSURL(fileURLWithPath: path)
		let filePath = url.appendingPathComponent(localPath)?.path
		let fileManager = FileManager.default
		if fileManager.fileExists(atPath: filePath!) {
			print("FILE AVAILABLE: \(filePath)")
			//TODO Set image
			return 0
		} else {
			print("FILE NOT AVAILABLE: \(filePath)")
			print("Downloading from \(remotePath)")
			//TODO Download
			//TODO Set image
			return 1
		}

	}
	
}
