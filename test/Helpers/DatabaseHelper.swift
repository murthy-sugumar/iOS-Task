//
//  DatabaseHelper.swift
//  test
//
//  Created by user184351 on 11/17/20.
//

import Foundation
import CoreData
import UIKit

class DatabaseHelper {
    
    static var shareInstance = DatabaseHelper()
    
    // Reference to managed object context
    var context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    func save(object : [String:String]) {
        let entity = NSEntityDescription.entity(forEntityName: "OfflineImage",in: context!)!
        let image = NSManagedObject(entity: entity,insertInto: context!)
        image.setValue(object["name"], forKeyPath: "imagename")
        
        do {
            try context?.save()
        } catch {
            print("data not saved")
        }
    }
    
    func getImageData() -> [OfflineImage] {
        var imageData = [OfflineImage]()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "OfflineImage")
        do {
            imageData = try context?.fetch(fetchRequest) as! [OfflineImage]
        } catch {
            print("can not get the data")
        }
        return imageData
    }
    
    func getImageFromDir(_ imageName: String) -> UIImage? {
        
        if let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsUrl.appendingPathComponent(imageName)
            do {
                let imageData = try Data(contentsOf: fileURL)
                return UIImage(data: imageData)
            } catch {
                print("Not able to load image")
            }
        }
        return nil
    }
}
