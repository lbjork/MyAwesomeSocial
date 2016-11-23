//
//  CircleView.swift
//  MyAwesomeSocial
//
//  Created by Lars Björk on 2016-11-20.
//  Copyright © 2016 Lars Björk. All rights reserved.
//

import UIKit

class CircleView: UIImageView {

    override func layoutSubviews() {
        layer.cornerRadius = self.frame.width / 2
    }

   

}
