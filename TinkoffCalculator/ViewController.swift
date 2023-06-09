//
//  ViewController.swift
//  TinkoffCalculator
//
//  Created by Kirill Varshamov on 08.06.2023.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func buttonPressed(_ sender: UIButton) {
        guard let buttonText = sender.titleLabel?.text else {
            return
        }
        print(buttonText)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Did load")
    }
}
