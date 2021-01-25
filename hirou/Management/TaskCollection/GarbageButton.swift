//
//  GarbageButton.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 22/06/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import AVFoundation
import UIKit

class GarbageButton: UIButton {
    var taskCollectionPointPosition: Int?;
    var taskPosition: Int?;

    override init(frame: CGRect) {
        super.init(frame: frame);
        self.layer.borderColor = UIColor.red.cgColor
        self.setTitle("*", for: .normal)
        self.titleLabel?.font = self.titleLabel?.font.withSize(20)
        configureButton()
    }

    init(frame: CGRect, taskCollectionPointPosition: Int, taskPosition: Int, taskCollection: TaskCollection) {
        self.taskCollectionPointPosition = taskCollectionPointPosition;
        self.taskPosition = taskPosition;
        super.init(frame: frame);
        self.layer.borderColor = UIColor.systemBlue.cgColor
        self.layer.backgroundColor = taskCollection.complete ? UIColor.systemGray3.cgColor : UIColor.white.cgColor
        self.setTitle(String(taskCollection.garbage.name.prefix(1)), for: .normal)
        self.titleLabel?.font = self.titleLabel?.font.withSize(15)
        configureButton()
    }
    
    func configureButton() {
        self.setTitleColor(.black, for: .normal)
        self.layer.borderWidth = 2
        self.layer.cornerRadius = 10
        self.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchDown)
    }
    
    @objc func buttonClicked(_ sender: UIButton) {
        let systemSoundID: SystemSoundID = 1103;
        AudioServicesPlaySystemSound(systemSoundID)
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
