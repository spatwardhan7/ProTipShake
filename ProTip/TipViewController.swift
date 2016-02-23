//
//  TipViewController.swift
//  ProTip
//
//  Created by Patwardhan, Saurabh on 2/21/16.
//  Copyright © 2016 honeybadgerinc. All rights reserved.
//

import UIKit

class TipViewController: UIViewController {

    let DEFAULT_TIP_KEY  = "DEFAULT TIP KEY"
    let LAST_BILL_AMOUNT = "LAST BILL AMOUNT"
    let LAST_TIP_INDEX = "LAST TIP INDEX"
    let LAST_CLOSED_DATE = "LAST CLOSED DATE"
    let DEFAULT_VALUE_CHANGED = "DEFAULT VALUE CHANGED"
    let RESTORED_STATE_KEY = "RESTORED STATE KEY"
    let DARK_THEME_KEY = "DARK THEME KEY"
    let LAUNCHED_BEFORE = "LAUNCHED BEFORE"

    let TIME_INTEVAL_FOR_RECONSTRUCT : Double = 600
    let DEFAULT_TIP : Int = 15
    let defaults = NSUserDefaults.standardUserDefaults()
    var restoredState = false
    
    @IBOutlet weak var billField: UITextField!
    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var tipPercentLabel: UILabel!
    @IBOutlet weak var tipPercentSlider: UISlider!
    @IBOutlet weak var tipHeaderLabel: UILabel!
    @IBOutlet weak var totalHeaderLabel: UILabel!
    @IBOutlet weak var separatorBarView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ProTip view did load")
        // Do any additional setup after loading the view, typically from a nib.
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "resigningActive",
            name: UIApplicationWillResignActiveNotification,
            object: nil
        )
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "becomeActive",
            name: UIApplicationDidBecomeActiveNotification,
            object: nil
        )
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "terminateActive",
            name: UIApplicationWillTerminateNotification,
            object: nil
        )
        checkLastClosed()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        billField.becomeFirstResponder()
        
        
        let isFirstLaunch = !defaults.boolForKey(LAUNCHED_BEFORE)
        if isFirstLaunch {
            defaults.setInteger(DEFAULT_TIP, forKey: DEFAULT_TIP_KEY)
            tipPercentSlider.value = Float(DEFAULT_TIP)
            updateUI()
            defaults.setBool(true, forKey: LAUNCHED_BEFORE)
        }
        
        applyTheme()
        restoredState = defaults.boolForKey(RESTORED_STATE_KEY)
        if !restoredState {
            setDefaults()
        }
        defaults.setBool(false, forKey: RESTORED_STATE_KEY)
    }
    
    @IBAction func onEditingChanged(sender: AnyObject) {
        updateUI()
    }

    @IBAction func onSliderValueChanged(sender: AnyObject) {
        updateUI()
    }
    
    
    @IBAction func onTap(sender: AnyObject) {
    }
    
    func resigningActive(){
        saveCurrentState()
    }
    
    func terminateActive(){
        saveCurrentState()
    }
    
    func becomeActive(){
        checkLastClosed()
    }
    
    func setDefaults(){
        let valueChanged = defaults.boolForKey(DEFAULT_VALUE_CHANGED)
        if valueChanged {
            let defaultTip = defaults.integerForKey(DEFAULT_TIP_KEY)
            tipPercentSlider.value = Float(defaultTip)
            updateUI()
        }
        
    }
    
    func saveCurrentState(){
        print("Saving Current State")
        defaults.setObject(billField.text, forKey: LAST_BILL_AMOUNT)
        defaults.setInteger(Int(roundValue(tipPercentSlider)), forKey: LAST_TIP_INDEX)
        defaults.setObject(NSDate(), forKey: LAST_CLOSED_DATE)
    }
    
    func checkLastClosed(){
        let lastDate = defaults.objectForKey(LAST_CLOSED_DATE) as? NSDate
        if lastDate != nil {
            let currentDate = NSDate()
            let timeInterval = currentDate.timeIntervalSinceDate(lastDate!)
            if timeInterval < TIME_INTEVAL_FOR_RECONSTRUCT {
                print("Time Interval: \(timeInterval)")
                let billAmount = defaults.objectForKey(LAST_BILL_AMOUNT) as? String
                if billAmount != nil {
                    defaults.setBool(true, forKey: RESTORED_STATE_KEY)
                    billField.text = billAmount
                    tipPercentSlider.value = Float(defaults.integerForKey(LAST_TIP_INDEX))
                    updateUI()
                }
            }
            else {
                print("Time Interval: \(timeInterval)")
                billField.text = ""
                tipPercentSlider.value = Float(defaults.integerForKey(DEFAULT_TIP_KEY))
                updateUI()
            }
        }
        else {
            print("lastDate is nil")
        }
    }
    
    func applyTheme(){
        if defaults.boolForKey(DARK_THEME_KEY) {
            view.backgroundColor = UIColor.lightGrayColor()
        } else{
            view.backgroundColor = UIColor.whiteColor()
        }
    }
    
    func updateUI(){
        let tipPercentage = Double(roundValue(tipPercentSlider))
        
        let billAmount = billField.text!._bridgeToObjectiveC().doubleValue
        let tip = billAmount * (tipPercentage * 0.01)
        let total = billAmount + tip
        
        let numberFortmatter = NSNumberFormatter()
        numberFortmatter.numberStyle = .CurrencyStyle
        tipLabel.text = numberFortmatter.stringFromNumber(tip)
        totalLabel.text = numberFortmatter.stringFromNumber(total)
        
        let tipPercentString = Int(roundValue(tipPercentSlider)).description + "%"
        
        tipPercentLabel.text = tipPercentString
        if tipPercentage <= 15 {
            tipPercentLabel.textColor = UIColor.greenColor()
            tipLabel.textColor = UIColor.greenColor()
        } else if tipPercentage <= 20 {
            tipPercentLabel.textColor = UIColor.orangeColor()
            tipLabel.textColor = UIColor.orangeColor()
        } else {
            tipPercentLabel.textColor = UIColor.redColor()
            tipLabel.textColor = UIColor.redColor()
        }
        
        if total > 0 {
            showHiddenFields(true)
        } else {
            showHiddenFields(false)
        }
    }
    
    func showHiddenFields(show: Bool){
        if show {
            tipHeaderLabel.alpha = 1
            tipLabel.alpha = 1
            separatorBarView.alpha = 1
            totalHeaderLabel.alpha = 1
            totalLabel.alpha = 1
        } else {
            tipHeaderLabel.alpha = 0
            tipLabel.alpha = 0
            separatorBarView.alpha = 0
            totalHeaderLabel.alpha = 0
            totalLabel.alpha = 0
        }
    }
    
    func roundValue(slider: UISlider) -> Float {
        return roundf(slider.value);
    }
}