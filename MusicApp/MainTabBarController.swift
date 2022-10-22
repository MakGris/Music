//
//  MainTabBarController.swift
//  MusicApp
//
//  Created by Maksim Grischenko on 07.10.2022.
//

import UIKit

protocol MAinTabBarControllerDelegate: AnyObject {
    func minimizeTrackDetailController()
    func maximizeTrackDetailController(viewModel: SearchViewModel.Cell?)
}

class MainTabBarController: UITabBarController {
    
    
    private var minimizedTopAnchorConstraint: NSLayoutConstraint!
    private var maximizedTopAnchorConstraint: NSLayoutConstraint!
    private var bottomAnchorConstraint: NSLayoutConstraint!
    
    let searchVC: SearchViewController = SearchViewController.loadFromStoryboard()
    let trackDetailView: TrackDetailView = TrackDetailView.loadFromNib()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.backgroundColor = .white
        
        tabBar.tintColor = UIColor(
            displayP3Red: 253/255,
            green: 45/255,
            blue: 85/255,
            alpha: 1
        )
        setupTrackDetailVIew()
        searchVC.tabBarDelegate = self
        
        viewControllers = [generateViewController(
            rootViewController: searchVC,
            image: UIImage(named: "Search") ?? UIImage(),
            title: "Search"
        ), generateViewController(
            rootViewController: ViewController(),
            image: UIImage(named: "Library") ?? UIImage(),
            title: "Library"
        )]
    }
    
    private func generateViewController(
        rootViewController: UIViewController,
        image: UIImage,
        title: String
    ) -> UIViewController {
        let navigationVC = UINavigationController(rootViewController: rootViewController)
        navigationVC.tabBarItem.image = image
        navigationVC.tabBarItem.title = title
        rootViewController.navigationItem.title = title
        navigationVC.navigationBar.prefersLargeTitles = true
        return navigationVC
    }
    
   
    
    private func setupTrackDetailVIew() {
        print("Тут мы будем настраивать TrackDetailView")
        
        trackDetailView.backgroundColor = .white
        trackDetailView.tabBarDelegate = self
        trackDetailView.delegate = searchVC
        view.insertSubview(trackDetailView, belowSubview: tabBar)
        
        trackDetailView.translatesAutoresizingMaskIntoConstraints = false
        
        maximizedTopAnchorConstraint = trackDetailView.topAnchor.constraint(
            equalTo: view.topAnchor,
            constant: view.frame.height
        )
        minimizedTopAnchorConstraint = trackDetailView.topAnchor.constraint(
            equalTo: tabBar.topAnchor,
            constant: -64)
        bottomAnchorConstraint = trackDetailView.bottomAnchor.constraint(
            equalTo: view.bottomAnchor,
            constant: view.frame.height
        )
        
        bottomAnchorConstraint.isActive = true
        maximizedTopAnchorConstraint.isActive = true
        
        trackDetailView.trailingAnchor.constraint(
            equalTo: view.trailingAnchor)
        .isActive = true
        trackDetailView.leadingAnchor.constraint(
            equalTo: view.leadingAnchor
        ).isActive = true
        
    }
}

extension MainTabBarController: MAinTabBarControllerDelegate {
    
    func maximizeTrackDetailController(viewModel: SearchViewModel.Cell?) {
        maximizedTopAnchorConstraint.isActive = true
        minimizedTopAnchorConstraint.isActive = false
        maximizedTopAnchorConstraint.constant = 0
        bottomAnchorConstraint.constant = 0
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 1,
            options: .curveEaseInOut) {
                self.view.layoutIfNeeded()
                self.tabBar.alpha = 0
            }
        guard let viewModel = viewModel else { return }
        self.trackDetailView.set(viewModel: viewModel)
    }
    
    func minimizeTrackDetailController() {
        maximizedTopAnchorConstraint.isActive = false
        bottomAnchorConstraint.constant = view.frame.height
        minimizedTopAnchorConstraint.isActive = true
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 1,
            options: .curveEaseInOut) {
                self.view.layoutIfNeeded()
                self.tabBar.alpha = 1
            }
    }
    
    
}
