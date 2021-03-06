//
//  RepositoryDetailRouter.swift
//  Swiftmazing
//
//  Created by Hélio Mesquita on 05/01/20.
//  Copyright (c) 2020 Hélio Mesquita. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

@objc protocol RepositoryDetailRoutingLogic {
    func routeToPage()
}

protocol RepositoryDetailDataPassing {
    var dataStore: RepositoryDetailDataStore? { get }
}

class RepositoryDetailRouter: RepositoryDetailRoutingLogic, RepositoryDetailDataPassing {

    weak var viewController: RepositoryDetailViewController?
    var dataStore: RepositoryDetailDataStore?

    func routeToPage() {
        guard let url = dataStore?.repository?.url else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

}
