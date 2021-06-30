
import UIKit

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        self.window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        self.window?.windowScene = windowScene
        self.window?.rootViewController = UIViewController()
        self.window?.makeKeyAndVisible()
        let sceneCoordinator = SceneCoordinator(window: self.window!)
        let authViewModel = AuthViewModel(coordinator: sceneCoordinator)
        let authScene = Scene.auth(authViewModel)
        sceneCoordinator.transition(to: authScene, type: .root)
    }

}

