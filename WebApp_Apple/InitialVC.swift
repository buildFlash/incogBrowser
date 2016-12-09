//
//  InitialVC.swift
//  WebApp_Apple
//
//  Created by Aryan Sharma on 09/12/16.
//  Copyright © 2016 Aryan Sharma. All rights reserved.
//

import UIKit

class InitialVC: UIViewController {
    
    @IBOutlet weak var googleBtn: UIButton!
    @IBOutlet weak var customBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "google" {
            if let vc = segue.destination as? ViewController {
                vc.url = NSURL(string: "https://www.duckduckgo.com")
            }
        }else if segue.identifier == "custom"{
            
        }
    }
    
    @IBAction func googleBtnPressed(_ sender: AnyObject) {
        performSegue(withIdentifier: "google", sender: nil)
        
           }
    
    @IBAction func customBtnPressed(_ sender: AnyObject) {
        performSegue(withIdentifier: "custom", sender: nil)
        
    }
    

    

}
