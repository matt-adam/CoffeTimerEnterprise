//
//  TimerDetailViewController.swift
//  Coffee Timer
//
//  Created by Ash Furrow on 2014-09-13.
//  Copyright (c) 2014 Ash Furrow. All rights reserved.
//

import UIKit

class TimerDetailViewController: UIViewController {

    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var startStopButton: UIButton!

    var timerModel: TimerModel!

    weak var timer: Timer?
    var notification: UILocalNotification?
    var timeRemaining: NSInteger {
        guard let fireDate = notification?.fireDate else {
            return 0
        }

        let now = Date()
        return NSInteger(round(fireDate.timeIntervalSince(now)))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = timerModel.name

        countdownLabel.text = timerModel.durationText

        timerModel.addObserver(self, forKeyPath: "duration", options: .new, context: nil)
        timerModel.addObserver(self, forKeyPath: "name", options: .new, context: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Request local notifications and set up local notification
        let settings = UIUserNotificationSettings(types: [.alert, .sound], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(settings)
    }

    @IBAction func buttonWasPressed(_ sender: AnyObject) {
        if let _ = timer {
            // Timer is running and button was pressed. Stop timer.
            stopTimer(.cancelled)
        } else {
            // Timer is not running and button is pressed. Start timer.
            startTimer()
        }
    }

    func timerFired() {
        if timeRemaining > 0 {
            updateTimer()
        } else {
            stopTimer(.completed)
        }
    }

    func updateTimer() {
        countdownLabel.text = String(format: "%d:%02d", timeRemaining / 60, timeRemaining % 60)
    }

    func startTimer() {
        navigationItem.rightBarButtonItem?.isEnabled = false
        navigationItem.setHidesBackButton(true, animated: true)
        startStopButton.setTitle(NSLocalizedString("Stop", comment: "Stop button title"), for: UIControlState())
        startStopButton.setTitleColor(.red, for: UIControlState())
        timer = Timer.scheduledTimer(timeInterval: 1,
            target: self,
            selector: #selector(TimerDetailViewController.timerFired),
            userInfo: nil,
            repeats: true)

        // Set up local notification
        let localNotification = UILocalNotification()
        localNotification.alertBody = NSLocalizedString("Timer Completed!", comment: "Timer completed alert body")
        localNotification.fireDate = Date().addingTimeInterval(TimeInterval(timerModel.duration))
        localNotification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.shared.scheduleLocalNotification(localNotification)

        notification = localNotification

        updateTimer()
    }

    enum StopTimerReason {
        case cancelled
        case completed
    }

    func stopTimer(_ reason: StopTimerReason) {
        navigationItem.rightBarButtonItem?.isEnabled = true
        navigationItem.setHidesBackButton(false, animated: true)
        countdownLabel.text = timerModel.durationText
        startStopButton.setTitle(NSLocalizedString("Start", comment: "Start button title"), for: UIControlState())
        startStopButton.setTitleColor(.green, for: UIControlState())
        timer?.invalidate()

        if reason == .cancelled {
            UIApplication.shared.cancelAllLocalNotifications()
        }
        notification = nil
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editDetail" {
            let navigationController = segue.destination as! UINavigationController
            let editViewController = navigationController.topViewController as! TimerEditViewController

            editViewController.timerModel = timerModel
        }
    }

    deinit {
        timerModel.removeObserver(self, forKeyPath: "duration")
        timerModel.removeObserver(self, forKeyPath: "name")
    }

    override func observeValue(forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?) {

        if keyPath == "duration" {
            countdownLabel.text = timerModel.durationText
        } else if keyPath == "name" {
            title = timerModel.name
        }
    }
}

extension TimerModel {
    var durationText: String {
        return String(format: "%d:%02d", duration / 60, duration % 60)
    }
}
