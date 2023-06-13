//
//  CalculationListViewController.swift
//  TinkoffCalculator
//
//  Created by Kirill Varshamov on 13.06.2023.
//

import UIKit

final class CalculationListViewController: UIViewController {

    var result: String?

    @IBOutlet weak var calculationLabel: UILabel!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        initialize()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }

    private func initialize() {
        modalPresentationStyle = .fullScreen
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        calculationLabel.text = result
    }
}
