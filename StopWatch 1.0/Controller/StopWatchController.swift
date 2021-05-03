//
//  StopWatchController.swift
//  StopWatch 1.0
//
//  Created by Marek Barták on 26.04.2021.
//

import UIKit

class StopWatchViewController: UIViewController {
    
    @IBOutlet weak var startAndStopButton: UIButton!
    @IBOutlet weak var labAndResetButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var labLabel: UILabel! {
        didSet {
            timeLabel.font = labLabel.font.monospacedDigitFont
        }
    }
    @IBOutlet weak var timeLabel: UILabel! {
        didSet {
            timeLabel.font = timeLabel.font.monospacedDigitFont
        }
    }

    var timer = Timer()
    var time = Time(startTimeInHundredth: 0)
    var watchIsCounting = false
    var laps: [Lap] = []
    var lapNumber = 0
    var labTimes = [Int]()


    func updateUI() {
        timeLabel.text = time.getTimeString(hundredts: time.displayTime)
        tableView.reloadData()
    }
    func lapAppend() {
        lapNumber = lapNumber + 1
        let lap = Lap(number: lapNumber, start: time.currentTimeInHundredth, leght: nil)
        laps.append(lap)
    }
    func lapGetLeght () {
        laps[lapNumber-1].leght = time.displayTime - labTimes.reduce(0,+)
        labTimes.append(laps[lapNumber-1].leght!)
    
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        startAndStopButton.layer.cornerRadius = 0.5 * startAndStopButton.bounds.size.height
        labAndResetButton.layer.cornerRadius = 0.5 * labAndResetButton.bounds.size.width
    }

    @IBAction func startStopPressed(_ sender: UIButton) {
        if watchIsCounting == false {
    // Start
            if lapNumber == 0 {
                lapAppend()
            }
            time.startTimeInHundredth = time.currentTimeInHundredth - (laps[lapNumber-1].leght ?? 0) 
            timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
            startAndStopButton.setTitle("Stop", for: .normal)
            labAndResetButton.setTitle("Lap", for: .normal)
            labAndResetButton.isEnabled = true
        } else {
    // Stop
            laps[lapNumber-1].leght = time.currentTimeInHundredth - time.startTimeInHundredth 
            timer.invalidate()
            startAndStopButton.setTitle("Start", for: .normal)
            labAndResetButton.setTitle("Reset", for: .normal)
        }
        watchIsCounting = !watchIsCounting
        }

    @IBAction func lapResetPressed(_ sender: UIButton) {
        if watchIsCounting == false {
    // Reset
            laps = []
            time.startTimeInHundredth = 0
            lapNumber = 0
            tableView.reloadData()
            timeLabel.text = time.getTimeString(hundredts: 0)
            labAndResetButton.isEnabled = false
            labTimes = []
        } else {
    // Lap
            lapGetLeght()
            lapAppend()
        }
    }
    @objc func updateTimer(){
        updateUI()
    }
}

// MARK: - Extension UITableViewDataSource
extension StopWatchViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return laps.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath)
        let order = lapNumber - indexPath.row // aby byly správně seřazeny (od zhora dolů)
        cell.detailTextLabel?.font = cell.detailTextLabel?.font.monospacedDigitFont
        cell.textLabel?.text = "Lab " + String(order)
        if indexPath.row == 0 {
        // první řádek
            let sumLeght = labTimes.reduce(0,+)
            let firstCell = time.displayTime - sumLeght
            cell.detailTextLabel?.text = time.getTimeString(hundredts: firstCell)
        } else {
        // další řádky
            let otherCell = laps[order-1].leght
            cell.detailTextLabel?.text = time.getTimeString(hundredts: otherCell!)
            cell.detailTextLabel?.textColor = UIColor.black
            cell.textLabel?.textColor = UIColor.black
        // barevně rozlišené největší a nejkratší kolo
            if lapNumber >= 3 {
                if otherCell == labTimes.max() {
                    cell.detailTextLabel?.textColor = UIColor.systemRed
                    cell.textLabel?.textColor = UIColor.systemRed
                } else if otherCell == labTimes.min() {
                    cell.detailTextLabel?.textColor = UIColor.systemGreen
                    cell.textLabel?.textColor = UIColor.systemGreen
                }
            }
        }
        return cell
    }

}

// MARK: - Extension UIFont

extension UIFont {
    var monospacedDigitFont: UIFont {
        let newFontDescriptor = fontDescriptor.monospacedDigitFontDescriptor
        return UIFont(descriptor: newFontDescriptor, size: 0)
    }
}

private extension UIFontDescriptor {
    var monospacedDigitFontDescriptor: UIFontDescriptor {
        let fontDescriptorFeatureSettings = [[UIFontDescriptor.FeatureKey.featureIdentifier: kNumberSpacingType,
                                              UIFontDescriptor.FeatureKey.typeIdentifier: kMonospacedNumbersSelector]]
        let fontDescriptorAttributes = [UIFontDescriptor.AttributeName.featureSettings: fontDescriptorFeatureSettings]
        let fontDescriptor = self.addingAttributes(fontDescriptorAttributes)
        return fontDescriptor
    }
}
    
