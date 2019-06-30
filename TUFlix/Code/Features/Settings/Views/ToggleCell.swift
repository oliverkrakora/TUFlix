//
//  ToggleCell.swift
//  TUFlix
//
//  Created by Oliver Krakora on 30.06.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import UIKit
import DataSource

struct ToggleItem {
    typealias ToggleClosure = ((_ isOn: Bool) -> Void)

    let title: String
    let isOn: Bool
    let toggleClosure: ToggleClosure?
}

class ToggleCell: UITableViewCell {
    
    @IBOutlet private var titleLabel: UILabel!
    
    @IBOutlet private var toggle: UISwitch!
    
    private var model: ToggleItem?
    
    func configure(with model: ToggleItem) {
        self.model = model
        self.toggle.isOn = model.isOn
        self.titleLabel.text = model.title
    }
    
    @IBAction private func didToggle(_ sender: UISwitch) {
        model?.toggleClosure?(sender.isOn)
    }
}

extension ToggleCell {
    static var descriptor: CellDescriptor<ToggleItem, ToggleCell> {
        return CellDescriptor().configure { (item, cell, _) in
            cell.configure(with: item)
            }.shouldHighlight { false }
    }
}
