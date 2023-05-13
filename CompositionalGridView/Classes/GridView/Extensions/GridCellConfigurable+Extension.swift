//
//  GridCellConfigurable+Extension.swift
//  CompositionalGridView
//
//  Created by TIENNV21 on 13/05/2023.
//  Copyright © 2023 tiennv166. All rights reserved.
//

import UIKit

extension GridCellConfigurable {
    func configureModel(_ model: GridItemModelConfigurable) -> UICollectionViewCell? {
        guard let model = model as? GridItemModel else { return (self as? UICollectionViewCell) }
        return configure(model)
    }
}
