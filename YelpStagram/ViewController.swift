//
//  ViewController.swift
//  YelpStagram
//
//   .
//  Copyright © 2020 Sam Meech-Ward. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
@IBOutlet weak var collectionView: UICollectionView!
    
 let networker = Networker.shared
 var places: [Place] = []
 var mainImage: UIImage?
 var searchTerm = "Cafe"
 var imageViews: [UIImageView] = []
 var selectedImage: UIImage?

    
 @IBOutlet weak var searchField: UISearchBar!
    
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    makeNewAPICall()
    collectionView.collectionViewLayout = layout()
    //set up tapGestureRecognizer for detecting view's pans and close the keyboard panel
    let tapGesture = UITapGestureRecognizer(
      target: self,
      action: #selector(viewTap)
        )
    view.addGestureRecognizer(tapGesture)
    }
  
    //initial API call
    func makeNewAPICall () {
        networker.getPlaces(term: searchTerm) { [weak self] places, error in
            if let error = error {
                print("Error getting places \(error)")
                return
            }
            guard let places = places else {
                print("Error getting places")
                return
            }
            self?.places = places
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
            }
        }
        
    }
    
    //set up coolection view
    private func layout() -> UICollectionViewCompositionalLayout {
            let layout = UICollectionViewCompositionalLayout { sectionIndex, environment -> NSCollectionLayoutSection? in
                    let itemSize = NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .estimated(400)
                    )
                    let item  = NSCollectionLayoutItem(layoutSize: itemSize)
                    
                    item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
                    
                    let groupSize = NSCollectionLayoutSize (
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .estimated(1000)
                    )
                    let columns = environment.container.contentSize.width > 500 ? 2 : 1
      
                    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
                    
                    group.interItemSpacing = .flexible(0)
                    
                    if columns > 1 {
                        group.contentInsets.leading = 0
                        group.contentInsets.trailing = 0
                
                    }
                    
                    let section = NSCollectionLayoutSection (group: group)

                    section.interGroupSpacing = 10
                    section.contentInsets.top = 10
                    
                    return section
                }
            
            let config = UICollectionViewCompositionalLayoutConfiguration()
            config.interSectionSpacing = 50
            layout.configuration = config

        return layout
        }
    
    //Shows selected image in full size
    @IBSegueAction func showFullSizeImage(_ coder: NSCoder) -> FullSizeImageViewController? {
        let vc = FullSizeImageViewController(coder: coder)
        vc?.image = selectedImage
        searchField.endEditing(true)
        return vc
    }
    
    //Detects taps for view and closes the keyboard
    @IBAction func viewTap(_ sender: UIPanGestureRecognizer) {
        searchField.endEditing(true)
    }
    

}

extension ViewController: UICollectionViewDataSource {
        func numberOfSections(in collectionView: UICollectionView) -> Int {
            return 1
        }
    
    
        func collectionView (_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return places.count
            
        }
        
        func collectionView (_ collectionView: UICollectionView, cellForItemAt
            indexPath: IndexPath) -> UICollectionViewCell {
            let place = places[indexPath.item]
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MyCollectionViewCell
            
//            cell.layer.shouldRasterize = true
//            cell.layer.rasterizationScale = UIScreen.main.scale
            
            cell.smallImageLabel.image = nil
            cell.photosArray.removeAll()
            
            cell.setup()
            cell.place = place
            cell.delegate = self
            
            let id = place.id
            cell.id = id
        
            networker.getImage(url: place.image_url) { (imageData: Data?, error: Error?) in
                if let error = error {
                    print("Error getting places \(error)")
                    return
                }
                guard let imageData = imageData else {
                    print("Error getting places")
                    return
                }
                if let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        //print(id, cell.id, id == cell.id)
                        if (cell.id == id) {
                            cell.smallImageLabel.image = image
                            
                        }
                    }
                }
            }
            networker.getImages(id: place.id) { (images, error) -> (Void) in
                if let error = error {
                    print("Error getting places \(error)")
                    return
                }
                guard let images = images else {
                    print("Error getting places")
                    return
                }
                let photosArray  = images.photos
                
//                let image = UIImage (named: "1")
//                cell.photosArray = [image!]
//                cell.update(images: cell.photosArray)
                
//                self.networker.getImage(url: image) { (imageData: Data?, error: Error?) in
//                        if let image = UIImage(data: imageData!) {
//                            DispatchQueue.main.async {
//                                print(id, cell.id, id == cell.id)
//                                    if (cell.id == id) {
//                                        cell.photosArray += [image]
//                                        cell.update(images: cell.photosArray)
//                                    }
//                           }
//                       }
//                    }
//                }
                
                
                
                photosArray?.forEach { photo in
                    self.networker.getImage(url: photo) { (imageData: Data?, error: Error?) in
                        if let image = UIImage(data: imageData!) {
                            DispatchQueue.main.async {
                                print(id, cell.id, id == cell.id)
                                    if (cell.id == id) {
                                        cell.photosArray += [image]
                                        cell.update(images: cell.photosArray)
                                    }
                           }
                       }
                    }
                }


            }
            
            return cell
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchField: UISearchBar) {
        searchField.resignFirstResponder()
        print(searchField.text ?? "")
        searchTerm = searchField.text ?? ""
        print(searchTerm)
        makeNewAPICall()
        searchField.text = ""
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //searchField.setBackgroundImage(UIImage(named: "orange"), for: .any, barMetrics: .default)
        searchField.barTintColor = #colorLiteral(red: 1, green: 0.6328433156, blue: 0, alpha: 1)
        searchField.textField?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        //searchField.setBackgroundImage(UIImage(named: "white"), for: .any, barMetrics: .default)
        searchField.barTintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        searchField.textField?.backgroundColor = #colorLiteral(red: 0.933308661, green: 0.9333030581, blue: 0.9375343323, alpha: 1)
        
    }
    
    
}


extension ViewController: MyCollectionViewCellDelegate {
    func myCollectionViewCell(_ cell: MyCollectionViewCell, didSelectImage image: UIImage) {
            selectedImage = image
        performSegue(withIdentifier: "fullImage", sender: self)
    }
    
}

extension UISearchBar {
  private func textField(superView: UIView) -> UITextField? {
    for view in superView.subviews {
      if view.isKind(of: UITextField.self) {
        return view as? UITextField
      }
      if let view = textField(superView: view) {
        return view
      }
    }
    
    return nil
  }
  var textField: UITextField? {
    return textField(superView: self)
  }
}
