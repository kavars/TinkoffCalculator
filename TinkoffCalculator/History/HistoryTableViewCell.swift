//
//  HistoryTableViewCell.swift
//  TinkoffCalculator
//
//  Created by Kirill Varshamov on 13.06.2023.
//

import UIKit

final class HistoryTableViewCell: UITableViewCell {

    @IBOutlet private weak var expressionLabel: UILabel!
    @IBOutlet private weak var resultLabel: UILabel!

    func configure(with expression: String, result: String) {
        expressionLabel.text = expression
        resultLabel.text = result
    }
}
