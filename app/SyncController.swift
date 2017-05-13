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

import UIKit
import CoreData

/**
The view controller of the app.
*/
class SyncController: UIViewController{
	
	@IBOutlet weak var pb: UIProgressView!
	@IBOutlet weak var lb: UILabel!
	
	var completion: Float = 0.0
	let messages: [String] = ["Contactando con Don Margolo...", "Arrancando la furgo...", "Preparando kalimotxos...",
	"Tú eres el piloto", "Afinando la tuba...", "Margolari camina pa'lante, margolari camina pa'trás.", "Ari ari ari!", "Llegando tarde", "¿Cabe más gente en el Foro Margolari?"]
	
	
	/**
	Run when the app loads.
	*/
	override func viewDidLoad() {
		
		NSLog(":SYNC:LOG: SyncController shown.")
		
		super.viewDidLoad()
		
		// Initial setup
		pb.progress = 0
		
		// Start the timer
		Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(progress), userInfo: nil, repeats: true)
		
	}
	
	func progress(){
		
		if (Int(completion * 100) % 20) == 0 {
			let rnd = Int(arc4random_uniform(UInt32(messages.count)));
			lb.text = messages[rnd]
		}
		
		completion = completion + 0.02
		
		if completion >= 1.0{
			completion = 0.0
		}
		pb.progress = completion
		
		
		
	}
	
}
