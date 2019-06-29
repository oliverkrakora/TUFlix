//
//  EpisodeListViewController.swift
//  TUFlix
//
//  Created by Oliver Krakora on 15.06.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import UIKit
import DataSource
import TUFlixKit
import ReactiveSwift

class EpisodeListViewController<T: ListViewModelProtocol>: ListViewController<T> {
    
    typealias SelectEpisodeCallback = ((EpisodeViewModel) -> Void)
    
    let toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.isHidden = true
        return toolbar
    }()
    
    let showEpisodeNamesToggle: UISwitch = {
        let toggle = UISwitch()
        toggle.addTarget(self, action: #selector(didToggleEpisodeNames), for: .valueChanged)
        return toggle
    }()
    
    private var disposable: Disposable?
    
    var selectEpisodeClosure: SelectEpisodeCallback!
    
    init(title: String?, viewModel: T, displayEpisodeNames: Bool = true) {
        self.showEpisodeNamesToggle.isOn = displayEpisodeNames
        super.init(title: title, viewModel: viewModel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolbar)
        
        let toggleEpisodeView = UIStackView()
        toggleEpisodeView.translatesAutoresizingMaskIntoConstraints = false
        toggleEpisodeView.axis = .horizontal
        toggleEpisodeView.alignment = .fill
        toggleEpisodeView.distribution = .fillProportionally
        
        let toggleLabel = UILabel()
        toggleLabel.text = L10n.Episodes.toggleTitle
        toggleLabel.textColor = .white
        
        toggleEpisodeView.addArrangedSubview(toggleLabel)
        
        let toggleStackView = UIStackView()
        toggleStackView.translatesAutoresizingMaskIntoConstraints = false
        toggleStackView.axis = .vertical
        toggleStackView.alignment = .trailing
        
        toggleStackView.addArrangedSubview(showEpisodeNamesToggle)
        toggleEpisodeView.addArrangedSubview(toggleStackView)
        
        let toolbarItem = UIBarButtonItem(customView: toggleEpisodeView)
        
        toolbar.setItems([toolbarItem], animated: true)
        
        NSLayoutConstraint.activate([
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.contentInset.bottom = toolbar.frame.height
    }
    
    override func cellDescriptors() -> [CellDescriptorType] {
        return [
            EpisodeCell.cellDescriptor
                .configure { [unowned self] (viewModel, cell, _) in
                    cell.configure(with: viewModel, showEpisodeNames: self.showEpisodeNamesToggle.isOn)
                }
                .didSelect { (viewModel, _) in
                    self.selectEpisodeClosure(viewModel)
                    return .keepSelected
                }.canEdit { true }
                .trailingSwipeAction { (row, _) -> UISwipeActionsConfiguration? in
                    guard let viewModel = row.item as? EpisodeViewModel else {
                        return nil
                    }
                    
                    let action: UIContextualAction = {
                        let title = viewModel.isFavorite ? L10n.Episode.removeLikeTitle : L10n.Episode.addLikeTitle
                        let action = UIContextualAction(style: .normal, title: title, handler: { (_, _, completion) in
                            if viewModel.isFavorite {
                                viewModel.unlikeEpisode()
                            } else {
                                viewModel.likeEpisode()
                            }
                            completion(true)
                        })
                        action.backgroundColor = viewModel.isFavorite ? Asset.unlikeColor.color : Asset.likeColor.color
                        return action
                    }()
                    
                    return UISwipeActionsConfiguration(actions: [
                        action
                        ])
            }
        ]
    }
    
    @objc private func didToggleEpisodeNames() {
        tableView.reloadData()
    }
}
