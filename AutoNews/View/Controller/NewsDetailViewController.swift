//
//  NewsDetailViewController.swift
//  AutoNews
//
//  Created by Антон Павлов on 08.10.2024.
//

import UIKit

final class NewsDetailViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private let newsItem: NewsItem
    
    // MARK: - UI Elements
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIDevice.current.userInterfaceIdiom == .pad ?
        UIFont.boldSystemFont(ofSize: 28) :
        UIFont.boldSystemFont(ofSize: 24)
        label.numberOfLines = 0
        label.textAlignment = .center
        
        return label
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        // 🎪 Адаптация размера шрифта для iPad и iPhone
        label.font = UIDevice.current.userInterfaceIdiom == .pad ?
        UIFont.systemFont(ofSize: 20) :  // iPad
        UIFont.systemFont(ofSize: 16)    // iPhone
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Назад", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(
            self,
            action: #selector(backButtonTapped),
            for: .touchUpInside
        )
        return button
    }()
    
    // MARK: - Initializer
    
    init(newsItem: NewsItem) {
        self.newsItem = newsItem
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addElements()
        setupLayoutConstraint()
        configureView()
    }
    
    // MARK: - Setup View
    
    private func addElements() {
        [titleLabel,
         imageView,
         descriptionLabel,
         backButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setupLayoutConstraint() {
        let sidePadding: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 100 : 16
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: sidePadding),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -sidePadding),
            
            imageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: sidePadding),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -sidePadding),
            imageView.heightAnchor.constraint(equalToConstant: 300),
            
            descriptionLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: sidePadding),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -sidePadding),
            
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            backButton.heightAnchor.constraint(equalToConstant: 50),
            backButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - Configure View with Data
    
    private func configureView() {
        titleLabel.text = newsItem.title
        descriptionLabel.text = newsItem.description
        ImageLoader.loadImage(from: newsItem.titleImageUrl) { [weak self] image in
            self?.imageView.image = image
        }
    }
    
    // MARK: - Action
    
    @objc private func backButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}
