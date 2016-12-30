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
    @IBOutlet weak var cancelBtn: UIButton!
    
    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        if let tapNumValue = defaults.string(forKey: "tapNum") {
            tapNumLbl.text = tapNumValue
            tapStepper.value = Double(tapNumValue)!
            
            if self == UIApplication.shared.keyWindow?.rootViewController {
                cancelBtn.isHidden = true
            } else {
                cancelBtn.isHidden = false
            }
        }
        
        if let touchNumValue = defaults.string(forKey: "touchNum") {
            touchNumLbl.text = touchNumValue
            touchStepper.value = Double(touchNumValue)!
        }

        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(screenEdgeSwiped))
        edgePan.edges = .right
        view.addGestureRecognizer(edgePan)
    }
    
    func screenEdgeSwiped(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        if recognizer.state == .recognized {
            print("Screen swiped from left edge!!")
            self.dismiss(animated: true, completion: nil)
        }
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
        if self == UIApplication.shared.keyWindow?.rootViewController {
            performSegue(withIdentifier: "initialSaveSegue", sender: nil)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    

    @IBAction func cancelBtnPressed(_ sender: Any) {
        if self != UIApplication.shared.keyWindow?.rootViewController {
            self.dismiss(animated: true, completion: nil)
        }
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
