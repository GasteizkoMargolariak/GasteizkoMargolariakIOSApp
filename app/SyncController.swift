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
	
	var delegate: AppDelegate?
	
	var nowSyncing: Bool = false
	var syncTimer: Timer? = nil
	
	@IBOutlet weak var pb: UIProgressView!
	@IBOutlet weak var lb: UILabel!
	@IBOutlet weak var lbTitle: UILabel!
	
	var completion: Float = 0.0
	let messages: [String] = ["Contactando con Don Margolo...", "Arrancando la furgo...", "Preparando kalimotxos...",
	"Tú eres el piloto", "Afinando la tuba...", "Margolari camina pa'lante, margolari camina pa'trás.", "Ari ari ari!", "Llegando tarde...", "¿Cabe más gente en el Foro Margolari?", "Arreglando el tirador de cerveza...", "Descorchando botellas...", "Repartiendo pulseras...", "Pintando las fiestas...", "Desplegando pancarta..."]
	
	
	/**
	Run when the app loads.
	*/
	override func viewDidLoad() {
		
		NSLog(":SYNCCONTROLLER:LOG: SyncController shown.")
		self.delegate = UIApplication.shared.delegate as? AppDelegate
		self.delegate?.syncController = self
		
		super.viewDidLoad()
		
		
		
	}
	
	override func viewDidAppear(_ animated: Bool) {
		if UserDefaults.standard.object(forKey: "userId") == nil{
			NSLog(":SYNCCONTROLLER:LOG: First run. Generating user ID and syncing...")
			let newUid = randomString(length: 16)
			let defaults = UserDefaults.standard
			defaults.set(newUid, forKey: "userId")
			// Initial setup
			pb.isHidden = false
			lbTitle.isHidden = false
			lb.isHidden = false
			pb.progress = 0
			
			// Start the timer
			Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(progress), userInfo: nil, repeats: true)
			
			syncTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(endSync), userInfo: nil, repeats: true)
			
			initialSync()
		}
		else{
			startApp()
		}
	}
	
	func endSync(){
		if self.nowSyncing == false{
			syncTimer?.invalidate()
			startApp()
		}
	}
	
	func startApp(){
		performSegue(withIdentifier: "SegueInit", sender: nil)
	}
	
	/**
	Handles the initial sync process.
	It can start it, showing the sync screen, or finish it, hidding the screen.
	:param: showScreen True to start the sync, false to end it.
	*/
	func initialSync(){
		//performSegue(withIdentifier: "SegueSync", sender: nil)
		Sync(synchronous: true)
	}
	
	
	/**
	Generates a random string to be used as a user identifier.
	:param: length The length of the generated string.
	:return: A random alphanumeric string with the indicated length.
	*/
	func randomString(length: Int) -> String {
		
		let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
		let len = UInt32(letters.length)
		
		var randomString = ""
		
		for _ in 0 ..< length {
			let rand = arc4random_uniform(len)
			var nextChar = letters.character(at: Int(rand))
			randomString += NSString(characters: &nextChar, length: 1) as String
		}
		
		return randomString
	}
	
	
	/**
	Signal to update the progressbar and, maybe, the tag.
	*/
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
