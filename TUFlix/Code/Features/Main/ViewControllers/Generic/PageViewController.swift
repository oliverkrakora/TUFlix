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
    
    private lazy var searchController: UISearchController = {
       let controller = UISearchController(searchResultsController: nil)
        controller.dimsBackgroundDuringPresentation = false
        controller.hidesNavigationBarDuringPresentation = true
        controller.obscuresBackgroundDuringPresentation = false
        return controller
    }()
    
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
        
        NSLayoutConstraint.activate([
            pagingViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pagingViewController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pagingViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pagingViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = segmentedControl
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        updateSearchController()
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
        if let searchbarDelegate = vc as? UISearchBarDelegate {
            searchController.searchBar.delegate = searchbarDelegate
            searchController.searchBar.isHidden = false
        } else {
            searchController.searchBar.delegate = nil
            navigationItem.searchController = nil
            searchController.searchBar.isHidden = true
        }
    }
}
