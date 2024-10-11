import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        
        var isIdea = DeviceStatus.shared.isIdea
        
        if isIdea {
            CategoryDataManager.getIdea { result in
                switch result {
                case .success(let url):
                    isIdea = true
                case .failure(let error):
                    isIdea = false
                }
                self.configureWindow(with: window, isIdea: isIdea)
            }
        } else {
            configureWindow(with: window, isIdea: isIdea)
        }
    }
    
    private func configureWindow(with window: UIWindow, isIdea: Bool) {
        DispatchQueue.main.async {
            let launchScreenViewController = LaunchScreenViewController(isIdea: isIdea)
            window.rootViewController = launchScreenViewController
            window.makeKeyAndVisible()
            self.window = window
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                let onboardingShown = UserDefaults.standard.bool(forKey: "HasLaunchedBefore")
                print("HasLaunchedBefore:", onboardingShown)
                
                if launchScreenViewController.isIdea {
                    if !onboardingShown {
                        let onboardingVC = OnboardingViewController(isIdea: isIdea)
                        window.rootViewController = onboardingVC
                    } else {
                        AppActions.shared.openWebPage()
                    }
                } else {
                    if !onboardingShown {
                        let onboardingVC = OnboardingViewController(isIdea: isIdea)
                        window.rootViewController = onboardingVC
                    } else {
                        let meetingVC = MeetingsViewController()
                        window.rootViewController = meetingVC
                    }
                }
                
                window.makeKeyAndVisible()
            }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}
