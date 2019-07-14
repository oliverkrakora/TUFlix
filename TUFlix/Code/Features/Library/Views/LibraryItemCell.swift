//
//  LibraryItemCell.swift
//  TUFlix
//
//  Created by Oliver Krakora on 20.06.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import UIKit
import DataSource

struct LibraryItem: Hashable, Diffable {
    let title: String
    let image: UIImage?
}

class LibraryItemCell: UITableViewCell {
    
    func configure(with item: LibraryItem) {
        self.textLabel?.text = item.title
        self.imageView?.image = item.image
    }
}

extension LibraryItemCell {
    static var cellDescriptor: CellDescriptor<LibraryItem, LibraryItemCell> {
        return CellDescriptor().configure { (item, cell, _) in
            cell.configure(with: item)
        }
    }
}
