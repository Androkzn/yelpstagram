//
//  Networker.swift
//  YelpStagram
//
//  Created by Andrei Tekhtelev on 2020-05-25.
//  Copyright © 2020 Sam Meech-Ward. All rights reserved.
//

import Foundation

enum NetworkerError: Error {
    case badResponse
    case badStatusCode(Int)
    case badData
}


class Networker {
     let bearer = "n38USiUEHcfBaP0NeA5UaBAN3sebIt5RuJK27NasFyGaM7wBKl_sq0FPjuUR_nOtpjpeFjQ2LMt7SfTj1Uw7VZXBMUWolrQea3ysItYKrGYa4fpIFEshS7G8ce3LXnYx"
    static let shared = Networker()
     
    private var images = NSCache<NSString, NSData>()
    
    
    private let session: URLSession
    
    init() {
        let config = URLSessionConfiguration.default
       session = URLSession(configuration: config)
    }
    
    
    func getPlaces(term: String, completion: @escaping ([Place]?, Error?) -> Void) {
           let url  = URL (string: "https://api.yelp.com/v3/businesses/search?term=\(term)&latitude=49.281815&longitude=-123.108414")!
           
           var request = URLRequest(url: url)
           request.setValue("Bearer \(bearer)", forHTTPHeaderField: "Authorization")
           request.httpMethod = "GET"

           
           let task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
               
               if let error = error {
                   DispatchQueue.main.async {
                   completion(nil, error)
                   }
                   return
               }
               
               guard let httpResponse = response as? HTTPURLResponse else {
                  DispatchQueue.main.async {
                   completion(nil, NetworkerError.badResponse)
                   }
                   return
               }
               
               guard (200...299).contains(httpResponse.statusCode) else {
                   DispatchQueue.main.async {
                       completion(nil, NetworkerError.badStatusCode(httpResponse.statusCode))
                   }
                   return
               }
               
               guard let data = data else {
                   DispatchQueue.main.async {
                       completion(nil, NetworkerError.badData)
                   }
                   return
               }
               
               do {
                 let result = try JSONDecoder().decode(ApiResult.self, from: data)
                   DispatchQueue.main.async {
                       completion(result.businesses, nil)
                   }
               } catch let error {
                 completion(nil, error)
               }
           }
           task.resume()
       }
    
    func getImage(url: String, completion: @escaping (_ imageData: Data?, Error?) -> (Void)) {
        let url  = URL (string: url)!
   
        if let imageData = images.object(forKey: url.absoluteString as NSString){
            print("using cached image \(url)")
            completion(imageData as Data,nil)
            return
        }
        
        let task = session.downloadTask(with: url) { (localUrl: URL?, response: URLResponse?, error: Error?) in
            if let error = error {
                DispatchQueue.main.async {
                completion(nil, error)
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
               DispatchQueue.main.async {
                completion(nil, NetworkerError.badResponse)
                }
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    completion(nil, NetworkerError.badStatusCode(httpResponse.statusCode))
                }
                return
            }
            
            guard let localUrl = localUrl else {
                DispatchQueue.main.async {
                    completion(nil, NetworkerError.badData)
                }
                return
            }
            
            do {
         
             let data = try Data (contentsOf: localUrl)
                DispatchQueue.main.async {
                    self.images.setObject(data as NSData, forKey: url.absoluteString as NSString)
                    completion(data, nil)
                    print("downloaded image \(url)")
                }
            } catch let error {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
    
     func getImages(id: String, completion: @escaping (Place?, Error?) -> Void) {
        let url  = URL  (string: "https://api.yelp.com/v3/businesses/\(id)")!
        //print("url: \(url)")
        var request = URLRequest(url: url)
        request.setValue("Bearer \(bearer)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"

            let task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
                
                if let error = error {
                    DispatchQueue.main.async {
                    completion(nil, error)
                    }
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                   DispatchQueue.main.async {
                    completion(nil, NetworkerError.badResponse)
                    }
                    return
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    DispatchQueue.main.async {
                        completion(nil, NetworkerError.badStatusCode(httpResponse.statusCode))
                    }
                    return
                }
                
                guard let data = data else {
                    DispatchQueue.main.async {
                        completion(nil, NetworkerError.badData)
                    }
                    return
                }
                
                do {
                  let result = try JSONDecoder().decode(Place.self, from: data)
                    DispatchQueue.main.async {
                        completion(result, nil)
                    }
                } catch let error {
                  completion(nil, error)
                }
            }
            task.resume()
        }

}
