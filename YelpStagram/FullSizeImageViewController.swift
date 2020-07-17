//
//  FullSizeImageViewController.swift
//  YelpStagram
//
//  Created by Andrei Tekhtelev on 2020-05-23.
//  Copyright © 2020 Sam Meech-Ward. All rights reserved.
//

import UIKit

class FullSizeImageViewController: UIViewController {

    var image: UIImage?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = image
        
        guard let image = image else {
          return
        }
        scrollView.minimumZoomScale = scrollView.frame.width/image.size.width
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        scrollView.minimumZoomScale = scrollView.frame.width/image.size.width
//    }
    
    @IBAction func closeButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension FullSizeImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
      return imageView
    }
}
