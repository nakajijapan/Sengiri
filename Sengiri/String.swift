//
//  String.swift
//  Sengiri
//
//  Created by nakajijapan on 2016/03/09.
//  Copyright © 2016 nakajijapan. All rights reserved.
//

import Foundation

extension String {

    var floatValue: Float {
        return (self as NSString).floatValue
    }

    var integerValue: Int {
        return (self as NSString).integerValue
    }

    var doubleValue: Double {
        return (self as NSString).doubleValue
    }

}