//
//  ViewController.swift
//  app
//
//  Created by Inigo Valentin on 28/09/16.
//  Copyright © 2016 Margolariak. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

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
        
        //Make the updatable
        //cell.setNeedsDisplay()
        //cell.setNeedsLayout()
        
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
        // Return all labels to their original state, and mark the selected as such
        var i = 0
        selected = indexPath.item
        for cell in collectionView.visibleCells as! [MenuCollectionViewCell]{
            print("\(i)/\(indexPath.item)")
            if i == indexPath.item{
                print("CHANGE")
                cell.bar.backgroundColor = UIColor(red: 90/255, green: 180/255, blue: 255/255, alpha: 1)
                cell.label.font = UIFont.boldSystemFont(ofSize: cell.label.font.pointSize)
            }
            else{
                cell.bar.backgroundColor = UIColor(red: 148/255, green: 209/255, blue: 255/255, alpha: 1)
                cell.label.font = UIFont.systemFont(ofSize: cell.label.font.pointSize)
                
            }
            //cell.superview?.superview?.setNeedsDisplay()
            //cell.setNeedsLayout()
            //DispatchQueue.main.async{cell.setNeedsDisplay()}
            i = i + 1
        }
        print("REDRAW")
        //collectionView.setNeedsDisplay()
        collectionView.layoutIfNeeded()
        //collectionView.setNeedsLayout()
        //DispatchQueue.main.async{collectionView.setNeedsDisplay()}
        //dispatch_async(dispatch_get_main_queue(), {collectionView.setNeedsDisplay()})
        
            
        
        //Mark the selected one
        //let sel = collectionView.visibleCells as! [[MenuCollectionViewCell]indexPath]
        
        
        //let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! MenuCollectionViewCell
        print("You selected cell #\(indexPath.item)!")
    }


}

