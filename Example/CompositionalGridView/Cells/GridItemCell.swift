//
//  GridItemCell.swift
//  CompositionalGridView_Example
//
//  Created by tiennv166 on 21/04/2023.
//  Copyright © 2023 tiennv166. All rights reserved.
//

import CompositionalGridView
import UIKit

struct GridItemCellModel {
    let identity: String = "\(UUID())"
    let image: UIImage? = ImageFactory.randomImage
    let width: CGFloat
    let height: CGFloat
    let index: Int
    let layoutIndex: GridLayout.Index
}

extension GridItemCellModel: GridItemModelConfigurable {
    var reuseIdentifier: String { "GridItemCell" }
    var viewType: GridLayout.ViewType { .cell(GridItemCell.self) }
    var itemSize: GridLayout.Size { .init(width: .fixed(width), height: .fixed(height)) }
    var lineSpacing: CGFloat { 12 }
    var itemSpacing: CGFloat { 12 }
}

final class GridItemCell: UICollectionViewCell {

    @IBOutlet private weak var gridImageView: UIImageView!
    @IBOutlet private weak var indexLabel: UILabel!
}

extension GridItemCell: GridCellConfigurable {
    func configure(_ model: GridItemModelConfigurable) -> UICollectionViewCell {
        guard let cellModel = model as? GridItemCellModel else { return self }
        gridImageView.image = cellModel.image
        indexLabel.text = "\(cellModel.index)"
        return self
    }
}


// MARK: ImageFactory

private enum ImageFactory {
    private static var names: [String] = [
        "1-1", "1-2", "1-3", "1-4", "1-5", "1-6", "1-7", "1-8", "1-9", "1-10", "1-11", "1-12", "1-13", "1-14", "1-15", "1-16", "1-17", "1-18", "1-19", "1-20"
    ]
    
    static var randomImage: UIImage? {
        let randomIdx = Int.random(in: 0..<ImageFactory.names.count)
        let imageName = ImageFactory.names[randomIdx]
        return UIImage(named: imageName)
    }
}
