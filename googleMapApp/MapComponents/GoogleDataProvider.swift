//
//  GoogleDataProvider.swift
//  googleMapApp
//
//  Created by Sumit Ghosh on 12/06/18.
//  Copyright © 2018 Sumit Ghosh. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import SwiftyJSON

typealias PlacesCompletion = ([GooglePlace]) -> Void
typealias PhotoCompletion = (UIImage?) -> Void

class GoogleDataProvider {
    let googleAPIKey = "AIzaSyCj6vrN95ANx4hzHE4EcfWGR-8HUi7h7wA"
    private var photoCache: [String: UIImage] = [:]
    private var placesTask: URLSessionDataTask?
    private var session: URLSession {
        return URLSession.shared
    }
    
    func fetchPlacesNearCoordinate(_ coordinate: CLLocationCoordinate2D, radius: Double, types: [String], completion: @escaping PlacesCompletion) -> Void {
        var urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(coordinate.latitude),\(coordinate.longitude)&radius=\(radius)&rankby=prominence&sensor=true&key=\(googleAPIKey)"
        let typesString = types.count > 0 ? types.joined(separator: "|") : "food"
        urlString += "&types=\(typesString)"
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? urlString
        
        guard let url = URL(string: urlString) else {
            completion([])
            return
        }
        
        if let task = placesTask, task.taskIdentifier > 0 && task.state == .running {
            task.cancel()
        }
        
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        placesTask = session.dataTask(with: url) { data, response, error in
            var placesArray: [GooglePlace] = []
            defer {
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    completion(placesArray)
                }
            }
            guard let data = data,
                let json = try? JSON(data: data, options: .mutableContainers),
                let results = json["results"].arrayObject as? [[String: Any]] else {
                    return
            }
            results.forEach {
                let place = GooglePlace(dictionary: $0, acceptedTypes: types)
                placesArray.append(place)
                if let reference = place.photoReference {
                    self.fetchPhotoFromReference(reference) { image in
                        place.photo = image
                    }
                }
            }
        }
        placesTask?.resume()
    }
    
    
    func fetchPhotoFromReference(_ reference: String, completion: @escaping PhotoCompletion) -> Void {
        if let photo = photoCache[reference] {
            completion(photo)
        } else {
            let urlString = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=200&photoreference=\(reference)&key=\(googleAPIKey)"
            guard let url = URL(string: urlString) else {
                completion(nil)
                return
            }
            
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            }
            
            session.downloadTask(with: url) { url, response, error in
                var downloadedPhoto: UIImage? = nil
                defer {
                    DispatchQueue.main.async {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        completion(downloadedPhoto)
                    }
                }
                guard let url = url else {
                    return
                }
                guard let imageData = try? Data(contentsOf: url) else {
                    return
                }
                downloadedPhoto = UIImage(data: imageData)
                self.photoCache[reference] = downloadedPhoto
                }
                .resume()
        }
    }
}

