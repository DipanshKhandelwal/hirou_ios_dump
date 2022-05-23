//
//  GarbageLineButton.swift
//  hirou
//
//  Created by ThuNQ on 5/13/22.
//  Copyright © 2022 Dipansh Khandelwal. All rights reserved.
//

import Foundation
import UIKit

class GarbageLineButton: UIButton {
    @IBOutlet var contentView: UIView!
    @IBOutlet var title: UILabel!
    @IBOutlet var subTitle: UILabel!
    @IBOutlet var icon: UIImageView!
    @IBOutlet weak var button: UIButton!
    
    
    private(set) var taskCollectionPointPosition: Int?;
    private(set) var taskPosition: Int?;
    
    var didClickedButton: ((GarbageLineButton)->())?
    
    init(tc: TaskCollection, garbageItem: GarbageListItem?, taskCollectionPointPosition: Int, taskPosition: Int) {
        super.init(frame: .zero)
        setTitle(nil, for: .normal)
        setImage(nil, for: .normal)
        setupButton()
        configButton(tc: tc, garbageItem: garbageItem)
        self.taskPosition = taskPosition
        self.taskCollectionPointPosition = taskCollectionPointPosition
        configureButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func configureButton() {
        button.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchDown)
    }
    
    @objc private func buttonClicked(_ sender: UIButton) {
        Sound.playInteractionSound()
        didClickedButton?(self)
    }
    
    private func setupButton() {
        layer.cornerRadius = 8
        clipsToBounds = true
        
        Bundle(for: type(of: self)).loadNibNamed("GarbageLineButton", owner: self, options: nil)
        addSubview(contentView)
        contentView.bringSubviewToFront(self)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    
    func configButton(tc: TaskCollection, garbageItem: GarbageListItem?) {
        guard let button = tc.garbage.customButton else { return }
        let color = tc.complete ? .white : button.color
        subTitle.text = "\(garbageItem?.complete ?? 0)/\(garbageItem?.total ?? 0)"
        subTitle.textColor = color
        title.text = tc.garbage.name
        title.textColor = color
        icon.image = button.iconLine?.withTintColor(color)
        contentView.backgroundColor = tc.complete ? button.color : .white
        self.backgroundColor = tc.complete ? button.color : .white
        self.viewBorderColor = color
        self.viewBorderWidth = 1
    }
}
