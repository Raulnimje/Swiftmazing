//
//  FeedViewController.swift
//  Swiftmazing
//
//  Created by Hélio Mesquita on 14/12/19.
//  Copyright (c) 2019 Hélio Mesquita. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit
import Visual

protocol FeedDisplayLogic: class {
    func show(_ viewModel: Feed.ViewModel)
    func showList()
    func showDetail()
    func showTryAgain(title: String, message: String)
}

class FeedViewController: FeedCollectionViewController<Feed.FeedCellViewModel> {

    var interactor: FeedBusinessLogic?
    var router: (FeedRoutingLogic & FeedDataPassing)?

    override func setup() {
        let viewController = self
        let interactor = FeedInteractor()
        let presenter = FeedPresenter()
        let router = FeedRouter()
        viewController.interactor = interactor
        viewController.router = router
        presenter.viewController = viewController
        interactor.presenter = presenter
        router.viewController = viewController
        router.dataStore = interactor
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        load()
    }

    private func configure() {
        title = Bundle.main.displayName
        collectionView.delegate = self
        collectionView.refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
    }

    @objc func load() {
        collectionView.refreshControl?.beginRefreshing()
        interactor?.loadScreen()
    }

    override func didSelectSupplementaryHeaderView(_ section: FeedSection) {
        didSelectSection(section)
    }

    func didSelectSection(_ section: FeedSection) {
        let repositories = dataSource.snapshot().itemIdentifiers(inSection: section).compactMap { $0.repository }
        switch section {
        case .topRepos:
            interactor?.topRepoListSelected(repositories, title: section.value)
        case .lastUpdated:
            interactor?.lastUpdatedListSelected(repositories, title: section.value)
        default:
            return
        }
    }

    func didSelectRepository(_ repository: Repository?) {
        interactor?.repositorySelected(repository)
    }

}

extension FeedViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let element = dataSource.itemIdentifier(for: indexPath) else { return }
        if FeedSection.allCases[indexPath.section] == .news {
            didSelectSection(element.section)
        } else {
            didSelectRepository(element.repository)
        }
    }

}

extension FeedViewController: FeedDisplayLogic {

    func show(_ viewModel: Feed.ViewModel) {
        var snapshot = NSDiffableDataSourceSnapshot<FeedSection, Feed.FeedCellViewModel>()
        snapshot.appendSections([.news, .topRepos, .lastUpdated])
        snapshot.appendItems(viewModel.news, toSection: .news)
        snapshot.appendItems(viewModel.topRepos, toSection: .topRepos)
        snapshot.appendItems(viewModel.lastUpdated, toSection: .lastUpdated)
        dataSource.apply(snapshot, animatingDifferences: false)
        collectionView.refreshControl?.endRefreshing()
    }

    func showList() {
        router?.routeToList()
    }

    func showDetail() {
        router?.routeToDetail()
    }

    func showTryAgain(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: Text.tryAgain.value, style: .default) { _ in
            self.interactor?.loadScreen()
        }
        alertController.addAction(action)
        present(alertController, animated: true)
    }

}
