//
//  SceneCoordinatorType.swift
//  Zabota
//
//  Created by Гороховский Никита on 27.05.2021.
//

import Foundation
import RxSwift

protocol SceneCoordinatorType {
    // transition on another scene
    @discardableResult
    func transition(to scene: Scene, type: SceneTransitionType) -> Completable
    
    // pop scene from navigation stack or dismiss current modal
    @discardableResult
    func pop(animated: Bool) -> Completable
}

extension SceneCoordinatorType {
    @discardableResult
    func pop() -> Completable {
        return pop(animated: true)
    }
}
