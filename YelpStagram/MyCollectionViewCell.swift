//
//  MyCollectionViewCell.swift
//  YelpStagram
//
//  Created by Andrei Tekhtelev on 2020-05-21.
//  Copyright © 2020 Sam Meech-Ward. All rights reserved.
//

import UIKit

protocol MyCollectionViewCellDelegate {
    func myCollectionViewCell(_ cell: MyCollectionViewCell, didSelectImage image: UIImage)
}


class MyCollectionViewCell: UICollectionViewCell {
    let networker = Networker.shared
    var delegate: MyCollectionViewCellDelegate?
    private var stackView: UIStackView!
    var smallImage: UIImage?
    var photosArray:  [UIImage] = []
    var id: String = ""
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var pageControlLabel: UIPageControl!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var openLabel: UILabel!
    @IBOutlet weak var smallImageLabel: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
     
    var place: Place? {
        didSet {
            if let place = place {
              titleLabel.text = place.name
              priceLabel.text = "\(place.price ?? "" )"
              ratingLabel.text = "Rating: \(place.rating)/5"
              openLabel.text = place.is_closed ? "Open ☕️" : "Close 😔"
              smallImageLabel.image = smallImage
              update(images: photosArray)
            }
        }
    }
    
    @IBAction func pageControl(_ pageControl: UIPageControl) {
        let offset = CGFloat(pageControl.currentPage)*scrollView.frame.width
        scrollView.setContentOffset(CGPoint (x: offset, y: 0), animated: true)
    }
    
    
    @objc func scrollTapped() {
        let pageIndex = Int(round(scrollView.contentOffset.x/frame.width))
        delegate?.myCollectionViewCell(self, didSelectImage: photosArray[pageIndex])
     }
}

extension MyCollectionViewCell {

func setup() {
    if stackView != nil {
      stackView.removeFromSuperview()
    }
    
    stackView = UIStackView()
    stackView.backgroundColor = UIColor.orange
    stackView.axis = .horizontal
    stackView.distribution = .fill
    stackView.alignment = .fill
    stackView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.addSubview(stackView)
    
    //set small image view as circle
    smallImageLabel.layer.cornerRadius = (smallImageLabel.frame.size.width ) / 2
    smallImageLabel.clipsToBounds = true
    smallImageLabel.layer.borderWidth = 3.0
    smallImageLabel.layer.borderColor = #colorLiteral(red: 1, green: 0.6328433156, blue: 0, alpha: 1)
    
    //set tapGestureRecognizer for detecting taps on scrollView
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(scrollTapped))
    scrollView.addGestureRecognizer(tapGesture)
  }
  
    func update(images: [UIImage]?) {
    
    guard let images = images else {
      return
    }
    
    // !!! cleans scroll view every tyme  !!!
    stackView.subviews.forEach { $0.removeFromSuperview() }
        
    let views = images.map { UIImageView(image: $0) }
    views.forEach { $0.contentMode = .scaleAspectFill }
    views.forEach(stackView.addArrangedSubview)
    
    NSLayoutConstraint.activate([
      stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
      stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
      stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
      stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor)
    ])
        
    stackView.alignment = .fill
    stackView.distribution = .fillEqually
    views.forEach { view in
      view.translatesAutoresizingMaskIntoConstraints = false
      view.isUserInteractionEnabled = true
      view.widthAnchor.constraint(equalTo: self.scrollView.frameLayoutGuide.widthAnchor).isActive = true
      view.heightAnchor.constraint(equalTo: self.scrollView.frameLayoutGuide.heightAnchor).isActive = true
    }
    
    pageControlLabel.numberOfPages = images.count
  }
  
  
}

//updates page control depending on scrollView's image
extension MyCollectionViewCell: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.x/scrollView.frame.width == 0 || scrollView.contentOffset.x/scrollView.frame.width == 1 ||  scrollView.contentOffset.x/scrollView.frame.width == 2) {
        let page = Int(round(scrollView.contentOffset.x/scrollView.frame.width))
        pageControlLabel.currentPage = page
        }
    }
}
