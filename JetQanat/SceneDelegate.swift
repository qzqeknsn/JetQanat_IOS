//
//  Untitled.swift
//  project_ios
//
//  Created by Abylay Zholdybay on 15.12.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    // Добавить это в AppDelegate.swift, если этого там нет
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // 1. Берем сцену
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // 2. Инициализируем окно
        let window = UIWindow(windowScene: windowScene)
        
        // 3. Создаем начальный экран (Welcome) обернутый в NavigationController
        let welcomeVC = WelcomeViewController()
        let navVC = UINavigationController(rootViewController: welcomeVC)
        navVC.setNavigationBarHidden(true, animated: false)
        
        // 4. Назначаем его главным
        window.rootViewController = navVC
        
        // 5. Показываем окно
        self.window = window
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
