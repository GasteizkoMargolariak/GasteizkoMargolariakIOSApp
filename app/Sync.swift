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

/**
 Class to handle server sync.
 */
class Sync{
    
    /**
     Starts the sync process.
    */
    init(){
        let url = buildUrl();
        sync(url: url)
    
    }
    
    /**
     Builds the URL to perform the sync against.
     :returns: The URL.
    */
    func buildUrl() -> URL{
        let url = URL(string: "https://margolariak.com/API/v1/sync.php?client=com.margolariak.app")
        //TODO add parameters
        return url!
        
    }
    
    /**
     Performs an asynchronous sync.
     It fethes the info from the server and stores as Core Data
     :param: url The url to sync.
    */
    func sync(url: URL){
        
        //Synchronously get data
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil else {
                print("error")
                return
            }
            guard let data = data else {
                print("Data is empty")
                return
            }
            
            let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [String:AnyObject]
            //print(json)
            print("Got the JSON")
            
            
            getTable(data: data AS String, table: "activities")
            
            
            //TODO: Do this for ech table
            /*
             let data = [
             (1, ["name": "United States of America", "short_name": "US"]),
             (2, ["name": "United Kingdom",           "short_name": "UK"]),
             (3, ["name": "France"])]
             
             let companiesTable = db["companies"] // get the table from our SQLite Database
             db.transaction(.Deferred) { txn in
             for (index,company) in data {
             if companiesTable.insert(name <- company["name"]!, shortname <- company["short_name"]).statement.failed {
             return .Rollback
             }
             }
             return .Commit
             }
             */
        }
        
        task.resume()

    }
    
    func getTable(data: String, table: String){
        //let index2 = data.index(data.startIndex, offsetBy: 2) //will call succ 2 times
        //let lastChar: Character = data[index2] //now we can index!
        
        //let characterIndex2 = data.characters.index(data.characters.startIndex, offsetBy: 2)
        //let lastChar2 = data.characters[characterIndex2] //will do the same as above
        
        //let range: Range<String.Index> = data.range(of: table)!
        //let index: Int = data.distance(from: data.startIndex, to: range.lowerBound)
        
        //print(data)
        
        //if let index = find(data, table) { // Unwrap the optional
        //    data.substringFromIndex(advance(index, 1)) // => "ABCDE"
        //}
    }
    
}
