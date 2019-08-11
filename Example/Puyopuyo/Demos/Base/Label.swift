//
//  Label.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/8/11.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

class Label: UILabel {
    convenience init(_ title: String?) {
        self.init(frame: .zero)
        self.text = title
        numberOfLines = 0
    }
}