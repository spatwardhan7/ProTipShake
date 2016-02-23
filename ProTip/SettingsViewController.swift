//
//  SettingsViewController.swift
//  ProTip
//
//  Created by Patwardhan, Saurabh on 2/21/16.
//  Copyright © 2016 honeybadgerinc. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    let DEFAULT_TIP_KEY = "DEFAULT TIP KEY"
    let DEFAULT_VALUE_CHANGED = "DEFAULT VALUE CHANGED"
    let DARK_THEME_KEY = "DARK THEME KEY"
    
    let defaults = NSUserDefaults.standardUserDefaults()

    @IBOutlet weak var themeSwitch: UISwitch!
    @IBOutlet weak var defaultTipPercentLabel: UILabel!
    @IBOutlet weak var defaultTipSlider: UISlider!
    @IBOutlet weak var jokeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Settings View didLoad")
        themeSwitch.on = defaults.boolForKey(DARK_THEME_KEY)
        setTheme(themeSwitch.on)
        jokeLabel.alpha = 0
        defaults.setBool(false, forKey: DEFAULT_VALUE_CHANGED)
        let defaultTipVal = defaults.integerForKey(DEFAULT_TIP_KEY)
        defaultTipPercentLabel.text = defaultTipVal.description + "%"
        defaultTipSlider.value = Float(defaultTipVal)
        setTipColor()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.becomeFirstResponder()
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake {
            print("Shake detected!")
            makeAPICall()
        }
    }
    
    @IBAction func onTipSliderValueChanged(sender: AnyObject) {
        let tipPercentString = Int(roundValue(defaultTipSlider)).description + "%"
        defaultTipPercentLabel.text = tipPercentString
        setTipColor()
        defaults.setInteger(Int(roundValue(defaultTipSlider)), forKey: DEFAULT_TIP_KEY)
        defaults.setBool(true, forKey: DEFAULT_VALUE_CHANGED)
    }
    
    @IBAction func onSwitchToggle(sender: AnyObject) {
        setTheme(themeSwitch.on)
        defaults.setBool(themeSwitch.on, forKey: DARK_THEME_KEY)
    }
    
    func setTheme(isDark: Bool){
        if isDark {
            view.backgroundColor = UIColor.lightGrayColor()
        }
        else {
            view.backgroundColor = UIColor.whiteColor()
        }
    }
    
    func roundValue(slider: UISlider) -> Float {
        return roundf(slider.value);
    }
    
    func setTipColor(){
        let tipPercentage = Double(roundValue(defaultTipSlider))
        if tipPercentage <= 15 {
            defaultTipPercentLabel.textColor = UIColor.greenColor()
        } else if tipPercentage <= 20 {
            defaultTipPercentLabel.textColor = UIColor.orangeColor()
        } else {
            defaultTipPercentLabel.textColor = UIColor.redColor()
        }
    }
    
    func makeAPICall(){
        let postEndpoint: String = "http://api.icndb.com/jokes/random?limitTo=[nerdy]"
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: postEndpoint)!
        
        session.dataTaskWithURL(url, completionHandler: { ( data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            // Make sure we get an OK response
            guard let realResponse = response as? NSHTTPURLResponse where
                realResponse.statusCode == 200 else {
                    print("Not a 200 response")
                    return
            }
            
            // Read the JSON
            do {
                if let responseString = NSString(data:data!, encoding: NSUTF8StringEncoding) {
                    // Print what we got from the call
                    print(responseString)
                    
                    // Parse the JSON to get the Joke
                    let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    let value = jsonDictionary["value"] as! NSDictionary
                    let joke = value["joke"] as! String
                    // Update the label
                    self.performSelectorOnMainThread("updateJokeLabel:", withObject: joke, waitUntilDone: false)
                    print(joke)
                }
            } catch {
                print("bad things happened")
            }
        }).resume()
    }
    
    func updateJokeLabel(joke: String){
        self.jokeLabel.alpha = 1
        self.jokeLabel.text = joke
        self.jokeLabel.numberOfLines = 0
        self.jokeLabel.sizeToFit()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
