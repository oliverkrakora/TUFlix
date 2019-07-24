//
//  ToggleToolbar.swift
//  TUFlix
//
//  Created by Oliver Krakora on 29.06.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import UIKit

class ToggleToolbar: UIToolbar {
    
    typealias ToggleCallback = ((_ isOn: Bool) -> Void)
    
    var didToggleClosure: ToggleCallback?
    
    let toggle: UISwitch = {
        let toggle = UISwitch()
        toggle.addTarget(self, action: #selector(didToggle(_:)), for: .valueChanged)
        return toggle
    }()
    
    let toggleLabel: UILabel = {
       let label = UILabel()
        label.textColor = Appearance.toggleToolbarLabelColor
        return label
    }()
    
    init(title: String, isOn: Bool, callback: ToggleCallback?) {
        didToggleClosure = callback
        super.init(frame: .zero)
        toggleLabel.text = title
        toggle.isOn = isOn
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        let toggleView = UIStackView()
        toggleView.translatesAutoresizingMaskIntoConstraints = false
        toggleView.axis = .horizontal
        toggleView.alignment = .fill
        toggleView.distribution = .fillProportionally
        
        toggleView.addArrangedSubview(toggleLabel)
        
        let toggleStackView = UIStackView()
        toggleStackView.translatesAutoresizingMaskIntoConstraints = false
        toggleStackView.axis = .vertical
        toggleStackView.alignment = .trailing
        
        toggleStackView.addArrangedSubview(toggle)
        toggleView.addArrangedSubview(toggleStackView)
        
        let toolbarItem = UIBarButtonItem(customView: toggleView)
        
        setItems([toolbarItem], animated: false)
    }
    
    @objc private func didToggle(_ sender: UISwitch) {
        didToggleClosure?(sender.isOn)
    }
}
