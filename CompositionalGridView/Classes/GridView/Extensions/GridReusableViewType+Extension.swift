//
//  GridReusableViewType+Extension.swift
//  CompositionalGridView
//
//  Created by TIENNV21 on 21/05/2023.
//  Copyright © 2023 tiennv166. All rights reserved.
//

import Foundation

extension GridReusableViewType {
    func configureModel(_ model: GridItemModelConfigurable) {
        (model as? GridItemModel).flatMap(configure)
    }
}
