//
//  MainTabBarController.swift
//  MusicApp
//
//  Created by Maksim Grischenko on 07.10.2022.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.backgroundColor = .white
        
        tabBar.tintColor = UIColor(
            displayP3Red: 253/255,
            green: 45/255,
            blue: 85/255,
            alpha: 1
        )
        let searchVC: SearchViewController = SearchViewController.loadFromStoryboard()
        
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
}
