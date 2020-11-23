//
//  ViewController.swift
//  test
//
//  Created by user184351 on 11/9/20.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // Identifiers
    let viewImageSegueIdentifier = "viewImageSegueIdentifier"
    let customCell = "customCell"
    let SearchBar = "SearchBar"
    
    var hits = [Hits]()
    
    var isNetworkConnected: Bool = Reachability.isConnectedToNetwork()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpCollectionView()
        loadOfflineData()
    }
    
    func loadOfflineData() {
        if isNetworkConnected {
            print("Internet Connection Available!")
        } else{
            print("Internet Connection not Available!")
            for offlineData in DatabaseHelper.shareInstance.getImageData() {
                self.hits.append(Hits(previewUrl: "", tags: offlineData.imagename ?? "",largeImageURL: ""))
            }
        }
    }
    
    private func setUpCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let item = sender as! Hits
        if segue.identifier == viewImageSegueIdentifier {
            if let vc = segue.destination as? ImageViewerViewController {
                vc.imageName = item.largeImageURL
                vc.imageLable = item.tags
            }
        }
    }
}

extension ViewController: UICollectionViewDataSource, UISearchBarDelegate, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hits.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: customCell, for: indexPath) as! CustomCollectionViewCell
        
        if isNetworkConnected {
            let imageName = hits[indexPath.row].tags.removingWhitespaces() + ".png"
            cell.imageView.downloadImageFromUrl(from: imageName, from: hits[indexPath.row].largeImageURL)
        } else {
            cell.imageView.image = DatabaseHelper.shareInstance.getImageFromDir(hits[indexPath.row].tags)
        }
        
        cell.imageView.contentMode = .scaleAspectFill
        cell.imageView.clipsToBounds = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = hits[indexPath.item]
        performSegue(withIdentifier: viewImageSegueIdentifier, sender: item)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let searchView: UICollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SearchBar, for: indexPath)
        return searchView
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.hits.removeAll()
        guard  let searchBarText = searchBar.text else {return}
        let completeUrl = "https://pixabay.com/api/?key=19132363-30dbe10600d01cb10a47614b3&q=" + searchBarText + "&image_type=photo&pretty=true"
        let url = URL(string:completeUrl)
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error == nil {
                do {
                    guard let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String: Any] else {return}
                    guard let hitsJson = json["hits"] as? [[String:Any]] else { return }
                    for json in hitsJson {
                        self.hits.append(Hits(previewUrl: json["previewURL"] as? String ?? "", tags: json["tags"] as? String ?? "", largeImageURL: json["largeImageURL"] as? String ?? ""))
                    }
                } catch let jsonErr {
                    print(jsonErr)
                }
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }.resume()
    }
}

extension String {
    func removingWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
}

extension UIImageView {
    
    func downloadImageFromUrl(from imageName: String, from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        contentMode = mode
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
            else { return }
            
            DispatchQueue.main.async() { [weak self] in
                self?.saveImage(imageName: imageName, image: image)
                self?.image = image
            }
        }.resume()
    }
    
    func downloadImageFromUrl(from imageName: String, from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadImageFromUrl(from: imageName, from: url, contentMode: mode)
    }
    
    func saveImage(imageName: String, image: UIImage) {
        
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileName = imageName
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        guard let data = image.jpegData(compressionQuality: 1) else { return }
        
        //Checks if file exists, otherwise skip.
        if FileManager.default.fileExists(atPath: fileURL.path) { } else {
            do {
                let imageData = ["name":fileName]
                DatabaseHelper.shareInstance.save(object: imageData as [String: String])
                try data.write(to: fileURL)
            } catch let error {
                print("error saving file with error", error)
            }
        }
    }
}
