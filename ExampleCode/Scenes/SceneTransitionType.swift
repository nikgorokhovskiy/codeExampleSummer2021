//
//  SceneTransitionType.swift
//  Zabota
//
//  Created by Гороховский Никита on 27.05.2021.
//

import UIKit

enum SceneTransitionType {
    // you can extend this to add animated transition types,
    // interactive transitions and even child view controllers!

    case root       // make view controller the root view controller
    case push       // push view controller to navigation stack
    case modal      // present view controller modally
    case child(UIViewController)      // add to view controller as child view controller
}
