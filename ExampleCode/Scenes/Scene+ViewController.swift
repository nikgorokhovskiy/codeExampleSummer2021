

import UIKit

extension Scene {
    
    func viewController() -> UIViewController {
        switch self {
        case .someScene(let viewModel):
            let vc = SomeSceneViewController()
            vc.bindViewModel(to: viewModel)
            return vc
        }
    }
}
