//
//  UIImageView+Extension.swift
//  hirou
//
//  Created by ThanhND on 5/24/22.
//  Copyright © 2022 Dipansh Khandelwal. All rights reserved.
//

import Foundation
import Kingfisher
import KingfisherWebP

extension UIImageView {
    
    func loadImage(urlString: String?,
                   placeholder: UIImage?,
                   showIndicator: Bool = false,
                   forceRefresh: Bool = false,
                   completion: ((_ image: UIImage?, _ error: Error?, _ url: URL?) -> Void)? = nil) {
        
        let url = URL(string: urlString ?? "")
        loadImage(url: url, placeholder: placeholder, showIndicator: showIndicator, forceRefresh: forceRefresh, completion: completion)
    }
    
    func loadImage(url: URL?,
                   placeholder: UIImage?,
                   showIndicator: Bool = false,
                   forceRefresh: Bool = false,
                   completion: ((_ image: UIImage?, _ error: Error?, _ url: URL?) -> Void)? = nil) {
        var options: KingfisherOptionsInfo = [.transition(.fade(0.1)),
                                              .cacheOriginalImage,
                                              .processor(WebPProcessor.default)]
        if forceRefresh {
            options.append(.forceRefresh)
        }
        self.kf.setImage(with: url, placeholder: placeholder, options: options, completionHandler: { result in
            switch result {
            case .success(let result):
                completion?(result.image, nil, result.source.url)
            case .failure(let err):
                completion?(nil, err, url)
            }
        })
    }
}
