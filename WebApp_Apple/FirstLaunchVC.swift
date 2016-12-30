//
//  FirstLaunchVC.swift
//  WebApp_Apple
//
//  Created by Aryan Sharma on 30/12/16.
//  Copyright © 2016 Aryan Sharma. All rights reserved.
//

import UIKit

class FirstLaunchVC: UIViewController {
    
    
    @IBOutlet weak var tapNumLbl: UILabel!
    @IBOutlet weak var touchNumLbl: UILabel!
    @IBOutlet weak var tapStepper: UIStepper!
    @IBOutlet weak var touchStepper: UIStepper!
    @IBOutlet weak var saveBtn: UIButton!
    
    let tapNumConstant = ""
    let touchNumConstant = ""
    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tapStepperPressed(_ sender: Any) {
        tapNumLbl.text = "\(Int(tapStepper.value))"
    }
    
    @IBAction func touchStepperPressed(_ sender: Any) {
        touchNumLbl.text = "\(Int(touchStepper.value))"
    }
    
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        defaults.set(Int(tapNumLbl.text!)!, forKey: "tapNum")
        defaults.set(Int(touchNumLbl.text!)!, forKey: "touchNum")
        performSegue(withIdentifier: "initialSaveSegue", sender: nil)
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "initialSaveSegue" {
//            print(segue.identifier!)
//            
//            if let vc = segue.destination as? ViewController {
//                vc.tap.numberOfTapsRequired = Int(tapNumLbl.text!)!
//                vc.tap.numberOfTouchesRequired = Int(touchNumLbl.text!)!
//            }
//        }
        
    }
    

}
