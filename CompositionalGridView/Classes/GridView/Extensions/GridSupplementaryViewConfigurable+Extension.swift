//
//  GridSupplementaryViewConfigurable+Extension.swift
//  CompositionalGridView
//
//  Created by TIENNV21 on 13/05/2023.
//  Copyright © 2023 tiennv166. All rights reserved.
//

import UIKit

extension GridSupplementaryViewConfigurable {
    func configureModel(_ model: GridItemModelConfigurable) -> UICollectionReusableView? {
        guard let model = model as? GridItemModel else { return (self as? UICollectionReusableView) }
        return configure(model)
    }
}
