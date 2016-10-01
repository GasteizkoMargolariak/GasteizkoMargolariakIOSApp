//
//  ViewController.swift
//  app
//
//  Created by Inigo Valentin on 28/09/16.
//  Copyright © 2016 Margolariak. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var sectionCollection: UICollectionView!

    @IBOutlet weak var containerViewLocation: UIView!
    @IBOutlet weak var containerViewHome: UIView!
    override func viewDidLoad() {
        print("LOAD")
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    let reuseIdentifier = "cell"
    var selected = 0
    var items = ["Home", "Location", "La Blanca", "Actividades", "Blog", "Gallery"]
    
    // MARK: - UICollectionViewDataSource protocol
    
    //Tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    //Make a cell for each section
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        print("SET: \(selected)/\(indexPath.item)")
        
        //Get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! MenuCollectionViewCell
        
        //Set text
        cell.label.text = self.items[indexPath.item]
        
        
        //Mark the first cell as selected
        if indexPath.item == selected{
            cell.bar.backgroundColor = UIColor(red: 90/255, green: 180/255, blue: 255/255, alpha: 1)
            cell.label.font = UIFont.boldSystemFont(ofSize: cell.label.font.pointSize)
        }
        else{
            cell.bar.backgroundColor = UIColor(red: 148/255, green: 209/255, blue: 255/255, alpha: 1)
            cell.label.font = UIFont.systemFont(ofSize: cell.label.font.pointSize)
        }
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        sectionCollection = collectionView
        print("You selected cell #\(indexPath.item)!")
        showComponent(selected: indexPath.item)
    }
    
    @IBAction func showComponent(selected: Int) {
        print("SELECTED: \(selected)")
        //Activate label
        var i = 0
        for cell in sectionCollection.visibleCells as! [MenuCollectionViewCell]{
            if i == selected + 1{
                cell.bar.backgroundColor = UIColor(red: 90/255, green: 180/255, blue: 255/255, alpha: 1)
                cell.label.font = UIFont.boldSystemFont(ofSize: cell.label.font.pointSize)
            }
            else{
                cell.bar.backgroundColor = UIColor(red: 148/255, green: 209/255, blue: 255/255, alpha: 1)
                cell.label.font = UIFont.systemFont(ofSize: cell.label.font.pointSize)
                
            }
            i = i + 1
        }
        
        //Show the view
        if selected == 0 {
            UIView.animate(withDuration: 0.5, animations: {
                self.containerViewHome.alpha = 1
                self.containerViewLocation.alpha = 0
            })
        } else if selected == 1 {
            UIView.animate(withDuration: 0.5, animations: {
                self.containerViewHome.alpha = 0
                self.containerViewLocation.alpha = 1
            })
        }
    }


}

