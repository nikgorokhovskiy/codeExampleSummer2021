
import UIKit
import RxSwift
import RxCocoa

class SceneCoordinator: NSObject, SceneCoordinatorType {
    
    // MARK: - Private properties
    
    private var window: UIWindow
    private var currentViewController: UIViewController
    
    // MARK: - Public properties
    
    static var presentedController: UIViewController? {
        let topController = UIApplication.shared.keyWindow?.rootViewController?.topController
        guard let navigation = topController as? UINavigationController else {
            return topController
        }
        return navigation.topViewController
    }
    
    static var rootViewController: UIViewController? {
        return UIApplication.shared.keyWindow?.rootViewController
    }
    
    static var shared: SceneCoordinator? = nil
    
    // MARK: - INIT
    
    required init(window: UIWindow) {
        self.window = window
        currentViewController = window.rootViewController!
        super.init()
        SceneCoordinator.shared = self
    }
    
    
    // MARK: - Public methods
    
    static func actualViewController(for viewController: UIViewController) -> UIViewController {
        if let navigationController = viewController as? UINavigationController {
            return navigationController.viewControllers.first!
        }
        return viewController
    }
    
    
    @discardableResult
    func transition(to scene: Scene, type: SceneTransitionType) -> Completable {
        let subject = PublishSubject<Void>()
        switch type {
        case .root:
            let viewController = scene.viewController()
            currentViewController = SceneCoordinator.actualViewController(for: viewController)
            window.rootViewController = viewController
            subject.onCompleted()
            
        case .push:
            let viewController = scene.viewController()
            guard let navigationController = currentViewController.navigationController else {
                fatalError("Can't push a view controller without a current navigation controller")
            }
            
            // prior to `navigationController.rx.delegate` as it takes care of preserving the configured delegate
            navigationController.delegate = self
            
            // one-off subscription to be notified when push complete
            _ = navigationController.rx.delegate
                .sentMessage(#selector(UINavigationControllerDelegate.navigationController(_:didShow:animated:)))
                .map { _ in }
                .bind(to: subject)
            
            navigationController.pushViewController(viewController, animated: true)
            
        case .modal:
            let viewController = scene.viewController()
            viewController.modalPresentationStyle = .overFullScreen
            currentViewController.present(viewController, animated: true) {
                subject.onCompleted()
            }
            currentViewController = SceneCoordinator.actualViewController(for: viewController)
            
        case .child(let childViewController):
            currentViewController.addChild(childViewController)
            childViewController.willMove(toParent: currentViewController)
            subject.onCompleted()
        }
        
        return subject.asObservable()
            .take(1)
            .ignoreElements()
            .asCompletable()
    }
    
    @discardableResult
    func pop(animated: Bool) -> Completable {
        let subject = PublishSubject<Void>()
        if let presenter = currentViewController.presentingViewController {
            // dismiss a modal controller
            currentViewController.dismiss(animated: true) {
                self.currentViewController = SceneCoordinator.actualViewController(for: presenter)
                subject.onCompleted()
            }
        } else if let navigationController = currentViewController.navigationController {
            _ = navigationController.rx.delegate
                .sentMessage(#selector(UINavigationControllerDelegate.navigationController(_:didShow:animated:)))
                .map { _ in }
                .bind(to: subject)
            guard navigationController.popViewController(animated: animated) != nil else {
                fatalError("Can't navigate back from \(currentViewController)")
            }
        } else {
            fatalError("Not a modal, no navigation controller: can't navigate back from \(currentViewController)")
        }
        return subject.asObservable()
            .take(1)
            .ignoreElements()
            .asCompletable()
    }
}

extension SceneCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        currentViewController = viewController
    }
}
