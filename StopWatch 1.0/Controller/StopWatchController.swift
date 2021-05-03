//
//  ViewController.swift
//  StopWatch 1.0
//
//  Created by Marek Barták on 26.04.2021.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var startAndStopButton: UIButton!
    @IBOutlet weak var labAndResetButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var labLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel! {
        didSet {
            timeLabel.font = timeLabel.font.monospacedDigitFont
        }
    }

    var timer = Timer()
    var time = Time(timeInHundredth: 0)
    var watchIsCounting = false
    var laps: [Lap] = []
    var lapNumber = 0
    var labTimes = [Int]()
    
    
    
    func updateUI() {
        timeLabel.text = time.getTimeString(hundredts: time.timeInHundredth)
        tableView.reloadData()
    }
    func lapAppend() {
        lapNumber = lapNumber + 1
        let lap = Lap(number: lapNumber, start: time.timeInHundredth, leght: nil)
        laps.append(lap)
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
            timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
            startAndStopButton.setTitle("Stop", for: .normal)
            labAndResetButton.setTitle("Lap", for: .normal)
            labAndResetButton.isEnabled = true
        } else {
    // Stop
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
            time.timeInHundredth = 0
            lapNumber = 0
            updateUI()
            labAndResetButton.isEnabled = false
            labTimes = []
        } else {
    // Lap
            lapAppend()
            laps[lapNumber-1].leght = time.timeInHundredth - laps[lapNumber-2].start
            labTimes.append(laps[lapNumber-1].leght!)
        }
    }
    @objc func updateTimer(){
        time.timeInHundredth = time.timeInHundredth + 1
        updateUI()
    }
}

// MARK: - Extension UITableViewDataSource
extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lapNumber
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath)
        let order = lapNumber - indexPath.row // aby byly správně seřazeny (od zhora dolů)
        cell.detailTextLabel?.font = cell.detailTextLabel?.font.monospacedDigitFont
        cell.textLabel?.text = String(order) + ". Lab"
        if indexPath.row == 0 {
            // první řádek
            let firstCell = time.timeInHundredth - laps[laps.count - 1].start
            cell.detailTextLabel?.text = time.getTimeString(hundredts: firstCell)
        } else {
        // další řádky
            let otherCell = laps[order].leght
            cell.detailTextLabel?.text = time.getTimeString(hundredts: otherCell!)
            cell.detailTextLabel?.textColor = UIColor.black
            cell.textLabel?.textColor = UIColor.black
            if lapNumber >= 3 {
            switch otherCell {
            case labTimes.max():
                cell.detailTextLabel?.textColor = UIColor.red
                cell.textLabel?.textColor = UIColor.red
            case labTimes.min():
                cell.detailTextLabel?.textColor = UIColor.green
                cell.textLabel?.textColor = UIColor.green
            default:
                cell.detailTextLabel?.textColor = UIColor.black
                cell.textLabel?.textColor = UIColor.black
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
    
