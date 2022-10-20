//
//  MainTabBarController.swift
//  MusicApp
//
//  Created by Maksim Grischenko on 07.10.2022.
//

import UIKit

protocol MAinTabBarControllerDelegate: AnyObject {
    func minimizeTrackDetailController()
}

class MainTabBarController: UITabBarController {
    
    let searchVC: SearchViewController = SearchViewController.loadFromStoryboard()
    
    private var minimizedTopAnchorConstraint: NSLayoutConstraint!
    private var maximizedTopAnchorConstraint: NSLayoutConstraint!
    private var bottomAnchorConstraint: NSLayoutConstraint!
    
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
        let trackDetailView: TrackDetailView = TrackDetailView.loadFromNib()
        trackDetailView.backgroundColor = .green
        trackDetailView.tabBarDelegate = self
        trackDetailView.delegate = searchVC
        view.insertSubview(trackDetailView, belowSubview: tabBar)
        
        trackDetailView.translatesAutoresizingMaskIntoConstraints = false
        
        maximizedTopAnchorConstraint = trackDetailView.topAnchor.constraint(
            equalTo: view.topAnchor
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
   
    func minimizeTrackDetailController() {
        maximizedTopAnchorConstraint.isActive = false
        minimizedTopAnchorConstraint.isActive = true
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 1,
            options: .curveEaseInOut) {
                self.view.layoutIfNeeded()
            }
    }
    
    
}
