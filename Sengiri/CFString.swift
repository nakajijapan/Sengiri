//
//  CFString.swift
//  Sengiri
//
//  Created by nakajijapan on 2017/01/03.
//  Copyright © 2017年 nakajijapan. All rights reserved.
//

import Foundation


extension CFString {
    
    var toString: String {
        let string = self as NSString
        return string as String
    }
    
}
