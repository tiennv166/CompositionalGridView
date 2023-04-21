//
//  UIView+Extension.swift
//  CompositionalGridView
//
//  Created by tiennv166 on 4/17/23.
//  Copyright © 2023 tiennv166. All rights reserved.
//

import UIKit

extension UIView {
    func fill(in container: UIView) {
        container.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 0),
            trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: 0),
            topAnchor.constraint(equalTo: container.topAnchor, constant: 0),
            bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: 0)
        ])
    }
}
