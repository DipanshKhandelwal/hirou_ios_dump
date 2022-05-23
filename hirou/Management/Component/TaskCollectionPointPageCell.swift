//
//  TaskCollectionPointPageCellCollectionViewCell.swift
//  hirou
//
//  Created by ThuNQ on 5/13/22.
//  Copyright © 2022 Dipansh Khandelwal. All rights reserved.
//

import UIKit

class TaskCollectionPointPageCell: UICollectionViewCell {
    @IBOutlet weak var sequence: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var memo: UILabel!
    @IBOutlet weak var garbageStack: UIStackView!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var stackGarbage1: UIStackView!
    @IBOutlet weak var stackGarbage2: UIStackView!
    @IBOutlet weak var btnInfomation: UIButton!
    @IBOutlet weak var btlToggleAll: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
