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
View controller to show a post.
*/
class PostViewController: UIViewController, UIGestureRecognizerDelegate {
	
	
	@IBOutlet weak var barTitle: UILabel!
	@IBOutlet weak var barButton: UIButton!
	@IBOutlet weak var postText: UILabel!
	@IBOutlet weak var postTitle: UILabel!
	@IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var postDate: UILabel!
    
	var id: Int = -1
	var passId: Int = -1
	var delegate: AppDelegate?
	

	/**
	Gets the application context.
	:return: Application context.
	*/
	func getContext () -> NSManagedObjectContext {
		return NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
	}
	
	
	/**
	Run when the app loads.
	*/
	override func viewDidLoad() {
		
		super.viewDidLoad()
		self.loadPost(id: id)
		
		// Set button action
		barButton.addTarget(self, action: #selector(self.back), for: .touchUpInside)
	}
		
	
	/**
	Dismisses the controller, efectively going to the previous section.
	*/
	@objc func back() {
		self.dismiss(animated: true, completion: nil)
	}
	
	
	/**
	Dispose of any resources that can be recreated.
	*/
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	

	/**
	Actually loads the post.
	:param: id Post id.
	*/
	public func loadPost(id: Int){
		
		let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let lang : String = getLanguage()
		context.persistentStoreCoordinator = appDelegate.persistentStoreCoordinator
		let fetchRequest: NSFetchRequest<Post> = Post.fetchRequest()
		fetchRequest.predicate = NSPredicate(format: "id = %i", id)
		
		do {
			let searchResults = try context.fetch(fetchRequest)
			
			var sTitle: String
			var sText: String
			var image: String
            var date: NSDate
			
			for r in searchResults as [NSManagedObject] {
				
				sTitle = r.value(forKey: "title_\(lang)")! as! String
				sText = r.value(forKey: "text_\(lang)")! as! String
				postTitle.text = "  \(sTitle.decode().stripHtml())"
				postText.text = sText.decode().stripHtml()
                date = r.value(forKey: "dtime")! as! NSDate
                postDate.text = formatDate(date: date, lang: lang)
				
				// Get main image
				image = ""
				let imgFetchRequest: NSFetchRequest<Post_image> = Post_image.fetchRequest()
				let imgSortDescriptor = NSSortDescriptor(key: "idx", ascending: true)
				let imgSortDescriptors = [imgSortDescriptor]
				imgFetchRequest.sortDescriptors = imgSortDescriptors
				imgFetchRequest.predicate = NSPredicate(format: "post == %i", id)
				imgFetchRequest.fetchLimit = 1
				do{
					let imgSearchResults = try context.fetch(imgFetchRequest)
					for imgR in imgSearchResults as [NSManagedObject]{
						image = imgR.value(forKey: "image")! as! String
						if image == ""{
							self.postImage.isHidden = true
						}
						else{
							let path = "img/blog/thumb/\(image)"
							self.postImage.setImage(localPath: path, remotePath: "https://margolariak.com/\(path)")
						}
					}
				}
				catch {
					NSLog(":POST:ERROR: Error getting image for post \(id): \(error)")
				}
				
			}
		}
		catch {
			NSLog(":POST:ERROR: Error with request: \(error)")
		}
	}
	
    
    /**
     Formats a date to the desired language.
     :param: text The date.
     :param: lang Device language (only 'es', 'en', or 'eu').
     */
    func formatDate(date: NSDate, lang: String) -> String{
        
        let months_es = ["0index", "enero", "febrero", "marzo", "abril", "mayo", "junio", "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre"]
        let months_en = ["0index", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
        let months_eu = ["0index", "urtarrilaren", "otsailaren", "martxoaren", "abrilaren", "maiatzaren", "ekainaren", "ustailaren", "abustuaren", "irailaren", "urriaren", "azaroaren", "abenduaren"]
        let days_es = ["0index", "Lunes", "Martes", "Miercoles", "Jueves", "Viernes", "Sábado", "Domingo"]
        let days_en = ["0index", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        let days_eu = ["0index", "Astelehena", "Asteartea", "Asteazkena", "Osteguna", "Ostirala", "Larumbata", "Igandea"]
        
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date as Date)
        let month = calendar.component(.month, from: date as Date)
        let weekday = calendar.component(.weekday, from: date as Date)
        var strDate = ""
        
        switch lang{
        case "en":
            
            var dayNum = ""
            switch day{
            case 1:
                dayNum = "1th"
                break
            case 2:
                dayNum = "2nd"
                break;
            case 3:
                dayNum = "3rd"
                break;
            default:
                dayNum = "\(day)th"
            }
            
            strDate = "\(days_en[weekday]), \(months_en[month]) \(dayNum)"
            break
        case "eu":
            strDate = "\(days_eu[weekday]) \(months_eu[month]) \(day)an"
            break
        default:
            strDate = "\(days_es[weekday]) \(day) de \(months_es[month])"
        }
        
        return strDate
    }
    
	
	/**
	Gets the device language. The only recognized languages are Spanish, English and Basque.
	If the device has another language, Spanish will be selected by default.
	:return: Two-letter language code.
	*/
	func getLanguage() -> String{
		let pre = NSLocale.preferredLanguages[0].subStr(start: 0, end: 1)
		if(pre == "es" || pre == "en" || pre == "eu"){
			return pre
		}
		else{
			return "es"
		}
	}
	
}

