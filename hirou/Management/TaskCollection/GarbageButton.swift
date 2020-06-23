//
//  GarbageButton.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 22/06/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import UIKit

class GarbageButton: UIButton {
    var taskCollectionPointPosition: Int;
    var taskPosition: Int;

    init(frame: CGRect, taskCollectionPointPosition: Int, taskPosition: Int) {
        self.taskCollectionPointPosition = taskCollectionPointPosition;
        self.taskPosition = taskPosition;
        super.init(frame: frame);
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
