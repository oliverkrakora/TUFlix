//
//  SimpleCell.swift
//  TUFlix
//
//  Created by Oliver Krakora on 17.07.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import UIKit
import DataSource

class SimpleCell: UITableViewCell {
    
}

extension SimpleCell {
    static var descriptor: CellDescriptor<String, SimpleCell> {
        return CellDescriptor().configure { (title, cell, _) in
            cell.textLabel?.text = title
        }
    }
}
