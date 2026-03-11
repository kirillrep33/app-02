//
//  GameViewController.swift
//  Iceberg Metaphor Builder
//
//  Created by test on 11.03.2026.
//

import UIKit
import SwiftUI

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Вместо SpriteKit‑сцены встраиваем SwiftUI‑иерархию с RootView.
        let hostingController = UIHostingController(rootView: RootView())

        addChild(hostingController)
        hostingController.view.frame = view.bounds
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
