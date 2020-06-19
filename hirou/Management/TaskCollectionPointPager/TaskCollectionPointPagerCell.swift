//
//  TaskCollectionPointPagerCell.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 16/06/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import UIKit
import FSPagerView

class TaskCollectionPointPagerCell: FSPagerViewCell {
    @IBOutlet weak var sequence: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var garbageStack: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
