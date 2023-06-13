//
//  ViewController.swift
//  TinkoffCalculator
//
//  Created by Kirill Varshamov on 08.06.2023.
//

import UIKit

enum CalculationError: Error {
    case dividedByZero
}

enum Operation: String {
    case add = "+"
    case substract = "-"
    case multiply = "x"
    case divide = "/"

    func calculate(_ number1: Double, _ number2: Double) throws -> Double {
        switch self {
        case .add:
            return number1 + number2
        case .substract:
            return number1 - number2
        case .multiply:
            return number1 * number2
        case .divide:
            if number2 == 0 {
                throw CalculationError.dividedByZero
            }
            return number1 / number2
        }
    }
}

enum CalculationHistoryItem {
    case number(Double)
    case operation(Operation)
}

class ViewController: UIViewController {

    private let alertView: AlertView = {
        let screenBounds = UIScreen.main.bounds
        let alertHeight: CGFloat = 100
        let alertWidth: CGFloat = screenBounds.width - 40
        let x: CGFloat = screenBounds.width / 2 - alertWidth / 2
        let y: CGFloat = screenBounds.height / 2 - alertHeight / 2
        let alertFrame = CGRect(x: x, y: y, width: alertWidth, height: alertHeight)
        let alertView = AlertView(frame: alertFrame)

        return alertView
    }()

    let calculationHistoryStorage = CalculationHistoryStorage()

    var calculations: [Calculation] = []

    @IBOutlet weak var label: UILabel!

    @IBAction func buttonPressed(_ sender: UIButton) {
        sender.animateTap()
        guard let buttonText = sender.titleLabel?.text else {
            return
        }

        if buttonText == "," && label.text?.contains(",") == true {
            return
        }

        if label.text == "0" {
            label.text = buttonText
        } else {
            label.text?.append(buttonText)
        }

        if label.text == "3,141592" {
            animateAlert()
        }
    }

    @IBAction func clearButtonPressed(_ sender: UIButton) {
        calculationHistory.removeAll()
        resetLabelText()
    }

    @IBAction func calculateButtonPressed(_ sender: UIButton) {
        guard
            let labelText = label.text,
            let labelNumber = numberFormatter.number(from: labelText)?.doubleValue
        else {
            return
        }

        calculationHistory.append(.number(labelNumber))

        do {
            let result = try calculate()
            label.text = numberFormatter.string(from: NSNumber(value: result))
            let newCalculation = Calculation(expression: calculationHistory, result: result)
            calculations.append(newCalculation)
            calculationHistoryStorage.setHistory(calculation: calculations)
        } catch {
            label.text = "Ошибка"
            label.shake()
        }

        calculationHistory.removeAll()
//        animateBackground()
    }

    @IBAction func unwindAction(unwindSegue: UIStoryboardSegue) {}

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            segue.identifier == "CALCULATION_LIST",
            let calculationsListVC = segue.destination as? CalculationListViewController
        else {
            return
        }

        calculationsListVC.calculations = calculations
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    func calculate() throws -> Double {
        guard
            case .number(let firstNumber) = calculationHistory[0]
        else { return 0 }

        var currentResult = firstNumber

        for index in stride(from: 1, to: calculationHistory.count - 1, by: 2) {
            guard
                case .operation(let operation) = calculationHistory[index],
                case .number(let number) = calculationHistory[index + 1]
            else {
                break
            }

            currentResult = try operation.calculate(currentResult, number)
        }

        return currentResult
    }

    @IBAction func operationButtonPressed(_ sender: UIButton) {
        guard
            let buttonText = sender.titleLabel?.text,
            let buttonOperation = Operation(rawValue: buttonText)
        else {
            return
        }

        guard
            let labelText = label.text,
            let labelNumber = numberFormatter.number(from: labelText)?.doubleValue
        else {
            return
        }

        calculationHistory.append(.number(labelNumber))
        calculationHistory.append(.operation(buttonOperation))

        resetLabelText()
    }

    var calculationHistory: [CalculationHistoryItem] = []

    lazy var numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.usesGroupingSeparator = false
        numberFormatter.locale = Locale(identifier: "ru_RU")
        numberFormatter.numberStyle = .decimal
        return numberFormatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Did load")
        calculations = calculationHistoryStorage.loadHistory()

        view.addSubview(alertView)
        alertView.alpha = 0
        alertView.alertText = "Вы нашли пасхалку!"

        view.subviews.forEach {
            if type(of: $0) == UIButton.self {
                $0.layer.cornerRadius = 45
            }
        }
    }

    func animateAlert() {
        if !view.contains(alertView) {
            alertView.alpha = 0
            alertView.center = view.center
            view.addSubview(alertView)
        }

//        UIView.animate(withDuration: 0.5) {
//            self.alertView.alpha = 1.0
//        }
//
//        UIView.animate(withDuration: 0.5, delay: 0.5) {
//            var newCenter = self.label.center
//            newCenter.y -= self.alertView.bounds.height
//            self.alertView.center = newCenter
//        }

        UIView.animateKeyframes(withDuration: 2.0, delay: 0.5) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5) {
                self.alertView.alpha = 1.0
            }

            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
                var newCenter = self.label.center
                newCenter.y -= self.alertView.bounds.height
                self.alertView.center = newCenter
            }
        }
    }

    func resetLabelText() {
        label.text = "0"
    }

    func animateBackground() {
        let animation = CABasicAnimation(keyPath: #keyPath(CALayer.backgroundColor))
        animation.duration = 1
        animation.fromValue = UIColor.white.cgColor
        animation.toValue = UIColor.systemGreen.cgColor

        view.layer.add(animation, forKey: #keyPath(CALayer.backgroundColor))
        view.layer.backgroundColor = UIColor.systemGreen.cgColor
    }
}

extension UILabel {

    func shake() {
        let animation = CABasicAnimation(keyPath: #keyPath(CALayer.position))
        animation.duration = 0.05
        animation.repeatCount = 5
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: center.x - 5, y: center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: center.x + 5, y: center.y))

        layer.add(animation, forKey: #keyPath(CALayer.position))
    }
}

extension UIButton {

    func animateTap() {
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.values = [1, 0.9, 1]
        scaleAnimation.keyTimes = [0, 0.2, 1]

        let opacityAnimation = CAKeyframeAnimation(keyPath: #keyPath(CALayer.opacity))
        opacityAnimation.values = [0.4, 0.8, 1]
        opacityAnimation.keyTimes = [0, 0.2, 1]

        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 1.5
        animationGroup.animations = [scaleAnimation, opacityAnimation]

        layer.add(animationGroup, forKey: "groupAnimation")
    }
}
