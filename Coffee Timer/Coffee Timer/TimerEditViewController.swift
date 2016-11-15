//
//  TimerEditViewController.swift
//  Coffee Timer
//
//  Created by Ash Furrow on 2014-09-13.
//  Copyright (c) 2014 Ash Furrow. All rights reserved.
//

import UIKit

@objc protocol TimerEditViewControllerDelegate {
    func timerEditViewControllerDidCancel(_ viewController: TimerEditViewController)
    func timerEditViewControllerDidSave(_ viewController: TimerEditViewController)
}

class TimerEditViewController: UIViewController {
    var creatingNewTimer = false
    weak var delegate: TimerEditViewControllerDelegate?

    var timerModel: TimerModel!

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var minutesLabel: UILabel!
    @IBOutlet weak var minutesSlider: UISlider!
    @IBOutlet weak var secondsLabel: UILabel!
    @IBOutlet weak var secondsSlider: UISlider!
    @IBOutlet weak var timerTypeSegmentedControl: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()

        let numberOfMinutes = Int(timerModel.duration / 60)
        let numberOfSeconds = Int(timerModel.duration % 60)
        nameField.text = timerModel.name
        updateLabelsWithMinutes(numberOfMinutes, seconds: numberOfSeconds)
        minutesSlider.value = Float(numberOfMinutes)
        secondsSlider.value = Float(numberOfSeconds)
        switch timerModel.type {
        case .coffee:
            timerTypeSegmentedControl.selectedSegmentIndex = 0
        case .tea:
            timerTypeSegmentedControl.selectedSegmentIndex = 1
        }
    }

    @IBAction func cancelWasPressed(_ sender: UIBarButtonItem) {
        delegate?.timerEditViewControllerDidCancel(self)
        presentingViewController?.dismiss(animated: true, completion: nil)
    }

    @IBAction func doneWasPressed(_ sender: UIBarButtonItem) {
        timerModel.name = nameField.text ?? ""
        timerModel.duration = Int32(minutesSlider.value) * 60 + Int32(secondsSlider.value)

        if timerTypeSegmentedControl.selectedSegmentIndex == 0 {
            timerModel.type = .coffee
        } else { // Must be 1
            timerModel.type = .tea
        }

        delegate?.timerEditViewControllerDidSave(self)
        presentingViewController?.dismiss(animated: true, completion: nil)
    }

    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let numberOfMinutes = Int(minutesSlider.value)
        let numberOfSeconds = Int(secondsSlider.value)
        updateLabelsWithMinutes(numberOfMinutes, seconds: numberOfSeconds)
    }

    func updateLabelsWithMinutes(_ minutes: Int, seconds: Int) {
        func pluralize(_ value: Int, singular: String, plural: String) -> String {
            switch value {
            case 1:
                return "1 \(singular)"
            case let pluralValue:
                return "\(pluralValue) \(plural)"
            }
        }

        minutesLabel.text = pluralize(minutes, singular: NSLocalizedString("minute", comment: "minute singular"), plural: NSLocalizedString("minutes", comment: "minute plural"))
        secondsLabel.text = pluralize(seconds, singular: NSLocalizedString("second", comment: "second singular"), plural: NSLocalizedString("seconds", comment: "second plural"))
    }
}
