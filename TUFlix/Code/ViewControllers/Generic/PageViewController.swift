//
//  PageViewController.swift
//  TUFlix
//
//  Created by Oliver Krakora on 14.06.19.
//  Copyright © 2019 aaa - all about apps GmbH. All rights reserved.
//

import UIKit

class PageViewController: UIViewController {
    
    /// ViewControllers that will be added as childs to the PageViewController
    var viewControllers = [UIViewController]() {
        didSet {
            segmentedControl.removeAllSegments()
            
            viewControllers.enumerated().forEach { enumeratedTuple in
                segmentedControl.insertSegment(withTitle: enumeratedTuple.element.navigationItem.title, at: enumeratedTuple.offset, animated: true)
            }
            
            pagingViewController.setViewControllers(viewControllers.first.flatMap { [$0] } ?? [], direction: .forward, animated: false, completion: nil)
            
            segmentedControl.selectedSegmentIndex = 0
            updateSearchController()
        }
    }
    
    var toolbar: UIToolbar? {
        didSet {
            setupToolbar()
        }
    }
    
    private var currentSegmentedControlIndex = 0
    
    private lazy var pagingViewController: UIPageViewController = {
        let vc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        return vc
    }()
    
    private lazy var segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(frame: .zero)
        control.addTarget(self, action: #selector(segmentedControlIndexDidChange), for: .valueChanged)
        return control
    }()
    
    var searchController: UISearchController? {
        return navigationItem.searchController
    }
    
    static func create(with viewControllers: [UIViewController]) -> PageViewController {
        let vc = PageViewController()
        vc.viewControllers = viewControllers
        return vc
    }
    
    override func loadView() {
        view = UIView()
        pagingViewController.view.translatesAutoresizingMaskIntoConstraints = false
        pagingViewController.willMove(toParent: self)
        view.addSubview(pagingViewController.view)
        pagingViewController.didMove(toParent: self)
        
        let bottomConstraint = pagingViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        
        bottomConstraint.priority = .defaultLow
        
        NSLayoutConstraint.activate([
            pagingViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pagingViewController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pagingViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomConstraint
            ])
        setupToolbar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = segmentedControl
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        updateSearchController()
    }
    
    private func setupToolbar() {
        if let toolbar = toolbar {
            toolbar.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(toolbar)
            NSLayoutConstraint.activate([
                toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                toolbar.topAnchor.constraint(equalTo: pagingViewController.view.bottomAnchor),
                toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                toolbar.bottomAnchor.constraint(equalTo: view.bottomAnchor)
                ])
        } else {
            toolbar?.removeFromSuperview()
        }
    }
    
    // MARK: Actions
    
    @objc private func segmentedControlIndexDidChange() {
        let vc = viewControllers[segmentedControl.selectedSegmentIndex]
        let navigationDirection: UIPageViewController.NavigationDirection = segmentedControl.selectedSegmentIndex > currentSegmentedControlIndex ? .forward : .reverse
        
        pagingViewController.setViewControllers([vc], direction: navigationDirection, animated: true, completion: nil)
        currentSegmentedControlIndex = segmentedControl.selectedSegmentIndex
        updateSearchController()
    }
    
    private func updateSearchController() {
        guard !viewControllers.isEmpty else { return }
        
        let vc = viewControllers[segmentedControl.selectedSegmentIndex]
        
        navigationItem.searchController = vc.navigationItem.searchController
        navigationItem.leftBarButtonItems = vc.navigationItem.leftBarButtonItems
        navigationItem.rightBarButtonItems = vc.navigationItem.rightBarButtonItems
        
        navigationController?.view.setNeedsLayout()
    }
}
