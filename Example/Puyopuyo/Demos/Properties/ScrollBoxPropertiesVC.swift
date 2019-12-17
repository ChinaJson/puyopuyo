//
//  ScrollBoxPropertiesVC.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/12/15.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Puyopuyo
import UIKit

class ScrollBoxPropertiesVC: BaseVC {
    override func configView() {
        ScrollBox(
            flow: {
//                HBox().attach()
                VFlow().attach()
                    .size(.fill, .wrap)
                    .arrangeCount(0)
                    .view
            },
            builder: {
                for i in 0 ..< 50 {
                    Label.demo("\(i)").attach($0)
                        .size(50, 50)
                }
            }
        )
        .attach(vRoot)
        .size(.fill, .fill)
        .margin(all: 10)
        .padding(all: 5)
    }

    override func shouldRandomColor() -> Bool {
        true
    }
}