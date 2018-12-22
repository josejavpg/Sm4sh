//
//  Helper.swift
//  Sm4sh
//
//  Created by José Javier on 12/2/18.
//  Copyright © 2018 José Javier. All rights reserved.
//

import Foundation
import UIKit

public func gradientView (_ view: UIView, startColor: CGColor, middleColor: CGColor, endColor: CGColor, frame: CGRect) {
  let gradient = CAGradientLayer()
  gradient.startPoint = CGPoint(x:0.0, y:0.0)
  gradient.endPoint = CGPoint(x:1.0, y:1.0)
  gradient.frame = frame
  gradient.colors = [startColor, middleColor, endColor]
  view.layer.insertSublayer(gradient, at: 0)
}

public func downloadImage(url: URL, image: UIImageView){
  getDataFromUrl(url: url) { (data, response, error)  in
    guard let data = data, error == nil else { return }
    DispatchQueue.main.async() { () -> Void in
      image.image = UIImage(data: data)
    }
  }
}

public func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
  URLSession.shared.dataTask(with: url) {
    (data, response, error) in
    completion(data, response, error)
    }.resume()
}
