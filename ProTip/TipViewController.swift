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
    @IBOutlet weak var tipSectionView: UIView!
    
    let TIME_INTEVAL_FOR_RECONSTRUCT : Double = 600
    let DEFAULT_TIP : Int = 15
    let defaults = NSUserDefaults.standardUserDefaults()
    var restoredState = false
    
    var initialBarSeparatorPosition : CGFloat = 0.0
    var initialBillLabelPosition : CGFloat = 0.0
    var initialBillFieldPosition : CGFloat = 0.0
    
    @IBOutlet weak var billField: UITextField!
    @IBOutlet weak var tipPercentHeaderLabel: UILabel!
    @IBOutlet weak var tipPercentLabel: UILabel!
    @IBOutlet weak var tipPercentSlider: UISlider!
    @IBOutlet weak var tipHeaderLabel: UILabel!
    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var totalHeaderLabel: UILabel!
    @IBOutlet weak var separatorBarView: UIView!
    @IBOutlet weak var billAmountLabel: UILabel!
    @IBOutlet weak var leftSideBar: UIView!
    @IBOutlet weak var rightSideBar: UIView!
    @IBOutlet weak var bottomBar: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ProTip view did load")
        // Do any additional setup after loading the view, typically from a nib.
        initialBarSeparatorPosition = self.separatorBarView.frame.size.height
        initialBillLabelPosition = self.billAmountLabel.center.y
        initialBillFieldPosition = self.billField.center.y
        
        self.tipSectionView.alpha = 0
        
        self.leftSideBar.alpha = 0
        self.rightSideBar.alpha = 0
        self.bottomBar.alpha = 0
        self.totalLabel.alpha = 0
        self.totalHeaderLabel.alpha = 0
        
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
        if tipPercentage <= 18 {
            tipPercentLabel.textColor = hexStringToUIColor("#5BE43A")
            tipLabel.textColor = hexStringToUIColor("#5BE43A")
        } else if tipPercentage <= 25 {
            tipPercentLabel.textColor = hexStringToUIColor("#FAB602")
            tipLabel.textColor = hexStringToUIColor("#FAB602")
        } else {
            tipPercentLabel.textColor = hexStringToUIColor("#AE153A")
            tipLabel.textColor = hexStringToUIColor("#AE153A")
        }
        
        if total > 0 {
            showHiddenFields(true)
        } else {
            showHiddenFields(false)
        }
    }
    
    func showHiddenFields(show: Bool){
        if show {
            UIView.animateWithDuration(0.5, animations: {
                self.separatorBarView.frame.size.height = 60
                self.billAmountLabel.center.y = 30
                self.billField.center.y = 30
                
                UIView.animateWithDuration(0.5, delay: 0.2, options: [], animations: {
                    self.tipSectionView.alpha = 1
                    self.tipHeaderLabel.alpha = 1
                    self.tipLabel.alpha = 1
                    self.tipPercentSlider.alpha = 1
                    self.tipPercentLabel.alpha = 1
                    self.tipPercentHeaderLabel.alpha = 1
                    
                    self.leftSideBar.alpha = 1
                    self.rightSideBar.alpha = 1
                    self.bottomBar.alpha = 1
                    self.totalLabel.alpha = 1
                    self.totalHeaderLabel.alpha = 1
                    }, completion: nil)
            })
        } else {
            UIView.animateWithDuration(0.5, animations: {
                self.separatorBarView.frame.size.height = self.initialBarSeparatorPosition
                self.billAmountLabel.center.y = self.initialBillLabelPosition
                self.billField.center.y = self.initialBillFieldPosition
                
                self.tipSectionView.alpha = 0
                self.tipHeaderLabel.alpha = 0
                self.tipLabel.alpha = 0
                self.tipPercentSlider.alpha = 0
                self.tipPercentLabel.alpha = 0
                self.tipPercentHeaderLabel.alpha = 0
                
                self.leftSideBar.alpha = 0
                self.rightSideBar.alpha = 0
                self.bottomBar.alpha = 0
                self.totalLabel.alpha = 0
                self.totalHeaderLabel.alpha = 0
            })
        }
    }
    
    func roundValue(slider: UISlider) -> Float {
        return roundf(slider.value);
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = cString.substringFromIndex(cString.startIndex.advancedBy(1))
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.grayColor()
        }
        
        var rgbValue:UInt32 = 0
        NSScanner(string: cString).scanHexInt(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}