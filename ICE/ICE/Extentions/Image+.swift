//
//  Image+.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/11/27.
//

import Foundation
import SwiftUI

extension UIImage {
    func isEmpty() -> Bool {
        self.size == CGSize.zero
    }
    
    func isNotEmpty() -> Bool {
        self.size != CGSize.zero
    }
    
    public convenience init(url: String) {
        let url = URL(string: url)
        do {
            let data = try Data(contentsOf: url!)
            self.init(data: data)!
            return
        } catch {
            
        }
        self.init()
    }
}
