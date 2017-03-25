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
			print("IMAGE:LOG: File available: \(filePath)")
			//TODO Set image
			return 0
		} else {
			print("IMAGE:LOG: File not available: \(filePath)")
			print("IMAGE:LOG: Downloading from \(remotePath)")
			//TODO Download
			//TODO Set image
			
			//Create required directories
			var fileFolderUrl = URL(fileURLWithPath: filePath!)
			fileFolderUrl.deleteLastPathComponent()
			print("IMAGE:DEBUG: Creating folder \(fileFolderUrl)")
			do{
				try fileManager.createDirectory(at:  fileFolderUrl, withIntermediateDirectories: true, attributes: nil)
			}
			catch(let error){
				print("IMAGE:ERROR: Error creating directories at \(fileFolderUrl.path): \(error.localizedDescription)")
			}
			
			// Create destination URL
			let documentsUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL!
			//let destinationFileUrl = URL(string: filePath!)//documentsUrl.appendingPathComponent("downloadedFile.jpg")
			let destinationFileUrl = URL(fileURLWithPath: filePath!)
			
			//Create URL to the source file you want to download
			let fileURL = URL(string: remotePath)
			
			let sessionConfig = URLSessionConfiguration.default
			let session = URLSession(configuration: sessionConfig)
			
			let request = URLRequest(url:fileURL!)
			
			let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
				if let tempLocalUrl = tempLocalUrl, error == nil {
					// Success
					if let statusCode = (response as? HTTPURLResponse)?.statusCode {
						print("IMAGE:LOG: Successfully downloaded. Status code: \(statusCode)")
					}
					
					do {
						try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
					} catch (let writeError) {
						print("IMAGE:ERROR: Error creating a file \(destinationFileUrl) : \(writeError)")
					}
					
				} else {
					print("IMAGE:ERROR: Error took place while downloading a file: %@", error?.localizedDescription);
				}
			}
			task.resume()
		
		
			return 1
		}

	}
	
}
