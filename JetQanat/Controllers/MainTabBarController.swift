//
//  MainTabBarController.swift
//  JetQanat
//
//  Created by Zholdibay Abylay on 15.12.2025.
//

import UIKit
import SnapKit

class MainTabBarController: UITabBarController {


    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBar()
        setupViewControllers()
    }

    private func configureTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 28/255, green: 28/255, blue: 35/255, alpha: 1.0)
        
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = .systemRed
        tabBar.unselectedItemTintColor = .gray
    }

    private func setupViewControllers() {
        let homeVC = HomeViewController()
        let homeNav = UINavigationController(rootViewController: homeVC)
        homeNav.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house.fill"), tag: 0)

        let marketVC = MarketplaceViewController()
        let marketNav = UINavigationController(rootViewController: marketVC)
        marketNav.tabBarItem = UITabBarItem(title: "Market", image: UIImage(systemName: "cart.fill"), tag: 1)

        let servicesVC = ServicesViewController()
        let servicesNav = UINavigationController(rootViewController: servicesVC)
        servicesNav.tabBarItem = UITabBarItem(title: "Services", image: UIImage(systemName: "wrench.and.screwdriver.fill"), tag: 2)
        
        let rentalsVC = RentalsViewController()
        let rentalsNav = UINavigationController(rootViewController: rentalsVC)
        rentalsNav.tabBarItem = UITabBarItem(title: "Rentals", image: UIImage(systemName: "calendar"), tag: 3)

        let profileVC = ProfileViewController()
        let profileNav = UINavigationController(rootViewController: profileVC)
        profileNav.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.fill"), tag: 4)

        viewControllers = [homeNav, marketNav, servicesNav, rentalsNav, profileNav]
    }
}
