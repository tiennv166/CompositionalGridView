//
//  LoadMoreCell.swift
//  CompositionalGridView
//
//  Created by tiennv166 on 4/17/23.
//  Copyright © 2023 tiennv166. All rights reserved.
//

import UIKit

struct LoadMoreCellModel: GridItemModelConfigurable {
    var identity: String { "\(String(describing: LoadMoreCell.self))" }
    var reuseIdentifier: String { "LoadMoreCell" }
    var viewType: GridLayout.ViewType { .cell(LoadMoreCell.self) }
    var itemSize: GridLayout.Size { GridLayout.Size(width: .fit, height: .fixed(60)) }
    var layoutIndex: GridLayout.Index {
        GridLayout.Index(section: GridLayout.Section(index: Int.max, style: .normal))
    }
}

// The cell is used for load more indicator at the bottom of collection view

final class LoadMoreCell: UICollectionViewCell {
    
    private let loadingIndicator = UIActivityIndicatorView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        contentView.backgroundColor = .clear
        loadingIndicator.style = .medium
        loadingIndicator.color = .black
        contentView.addSubview(loadingIndicator)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 0),
            loadingIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0)
        ])
    }
}

extension LoadMoreCell: GridReusableViewType {
    func configure(_ model: LoadMoreCellModel) {
        if !loadingIndicator.isAnimating {
            loadingIndicator.startAnimating()
        }
    }
}
