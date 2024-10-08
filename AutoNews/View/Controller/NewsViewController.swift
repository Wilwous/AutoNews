//
//  NewsViewController.swift
//  AutoNews
//
//  Created by Антон Павлов on 07.10.2024.
//

import UIKit
import Combine

final class NewsViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private var viewModel = NewsViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    private lazy var loadingView = LoadingView()
    
    private lazy var collectionView: UICollectionView = {
        let layout = createLayout()
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.register(NewsCell.self, forCellWithReuseIdentifier: NewsCell.identifier)
        view.backgroundColor = .white
        view.delegate = self
        view.dataSource = self
        view.showsVerticalScrollIndicator = false
        
        return view
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addElements()
        setupLayoutConstraint()
        bindViewModel()
        viewModel.loadNews()
    }
    
    // MARK: - Setup View
    
    private func addElements() {
        [collectionView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setupLayoutConstraint() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, environment) -> NSCollectionLayoutSection? in
            let availableWidth = environment.container.effectiveContentSize.width
            let columns: Int
            let spacing: CGFloat
            
            if availableWidth > 600 {
                columns = 2
                spacing = 20
            } else {
                columns = 1
                spacing = 8
            }
            
            let totalSpacing = spacing * CGFloat(columns + 1)
            let itemWidth = (availableWidth - totalSpacing) / CGFloat(columns)
            
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .absolute(itemWidth),
                heightDimension: .absolute(320)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: spacing, bottom: 0, trailing: spacing)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(320)
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = spacing
            section.contentInsets = NSDirectionalEdgeInsets(top: spacing, leading: spacing, bottom: spacing, trailing: spacing)
            
            return section
        }
    }
    
    // MARK: - Private Methods
    
    private func bindViewModel() {
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                guard let self = self else { return }
                if isLoading {
                    self.loadingView.showLoader(in: self.view)
                } else {
                    self.loadingView.hideLoader()
                }
            }
            .store(in: &cancellables)
        
        viewModel.$newsList
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newNewsList in
                guard let self = self else { return }
                
                let oldNewsList = self.viewModel.oldNewsList
                let diff = newNewsList.difference(from: oldNewsList)
                
                self.collectionView.performBatchUpdates({
                    for change in diff {
                        switch change {
                        case let .remove(offset, _, _):
                            let indexPath = IndexPath(item: offset, section: 0)
                            self.collectionView.deleteItems(at: [indexPath])
                        case let .insert(offset, _, _):
                            let indexPath = IndexPath(item: offset, section: 0)
                            self.collectionView.insertItems(at: [indexPath])
                        }
                    }
                }, completion: { _ in
                    self.viewModel.oldNewsList = newNewsList
                })
            }
            .store(in: &cancellables)
        
        viewModel.$errorMessage
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                guard let self = self else { return }
                AlertHelper.showAlert(on: self, title: "Ошибка", message: errorMessage)
            }
            .store(in: &cancellables)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension NewsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return viewModel.newsList.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: NewsCell.identifier,
            for: indexPath
        ) as? NewsCell else {
            return UICollectionViewCell()
        }
        
        let newsItem = viewModel.newsList[indexPath.row]
        cell.configure(with: newsItem)
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
        
        if offsetY > (contentHeight - frameHeight - 100) && !viewModel.isLoading {
            viewModel.loadMoreNews()
        }
    }
    
    // MARK: - Animations
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? NewsCell else { return }
        
        UIView.animate(withDuration: 0.2, animations: {
            cell.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }, completion: { _ in
            UIView.animate(withDuration: 0.2, animations: {
                cell.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }, completion: { _ in
                UIView.animate(withDuration: 0.2, animations: {
                    cell.transform = CGAffineTransform.identity
                }, completion: { _ in
                    let selectedNews = self.viewModel.newsList[indexPath.item]
                    let detailVC = NewsDetailViewController(newsItem: selectedNews)
                    self.present(detailVC, animated: true, completion: nil)
                })
            })
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? NewsCell else { return }
        UIView.animate(withDuration: 0.2) {
            cell.transform = CGAffineTransform.identity
        }
    }
}
