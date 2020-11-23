//
//  ImageViewerViewController.swift
//  test
//
//  Created by user184351 on 11/17/20.
//

import UIKit

class ImageViewerViewController: UIViewController {
    
    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var ImageLable: UILabel!
    
    var imageName: String!
    var imageLable: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupImageView()
    }
    
    private func setupImageView() {
        guard let imageUrl = imageName else {return}
        guard let imageName = imageLable else {return}
        let offlineImage = DatabaseHelper.shareInstance.getImageFromDir(imageName)
        if offlineImage != nil {
            ImageView.image = offlineImage
        } else {
            ImageView.downloadImageFromUrl(from: imageName, from: imageUrl)
        }
        
        ImageView.clipsToBounds = true
        ImageLable.text = imageName
    }
}
