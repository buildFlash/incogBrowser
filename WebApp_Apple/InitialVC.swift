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
    @IBOutlet weak var bingBtn: UIButton!
    @IBOutlet weak var ddgBtn: UIButton!
    
    var searchEngine: String!

    let vc = ViewController()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.layer.cornerRadius = 10
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
            print(segue.identifier!)

            if let vc = segue.destination as? ViewController {
                if searchEngine == "Google" {
                        vc.url = NSURL(string: "https://www.google.com")
                        vc.segueUsed = "google"
                        vc.searchEngine = "google"
                }
                
                else if searchEngine == "Bing" {
                        vc.url = NSURL(string: "https://www.bing.com")
                        vc.segueUsed = "google"
                        vc.searchEngine = "bing"
                }
                
                else if searchEngine == "DuckDuckGo" {
                        vc.url = NSURL(string: "https://www.duckduckgo.com")
                        vc.segueUsed = "google"
                        vc.searchEngine = "duckduckgo"
                }
            }
            
        }else if segue.identifier == "custom"{
            print(segue.identifier!)
            if let vc = segue.destination as? ViewController {
                vc.segueUsed = "custom"
            }
        }
    }
    
    @IBAction func googleBtnPressed(_ sender: AnyObject) {
        searchEngine = "Google"
        print(searchEngine)
        performSegue(withIdentifier: "google", sender: nil)
        
    }
    
    @IBAction func bingBtnPressed(_ sender: AnyObject) {
        searchEngine = "Bing"
        print(searchEngine)
        performSegue(withIdentifier: "google", sender: nil)
        
    }
    
    @IBAction func ddgBtnPressed(_ sender: AnyObject) {
        searchEngine = "DuckDuckGo"
        print(searchEngine)
        performSegue(withIdentifier: "google", sender: nil)
        
    }
    
    @IBAction func customBtnPressed(_ sender: AnyObject) {
        performSegue(withIdentifier: "custom", sender: nil)
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // ViewControllers view ist fully loaded and could present further ViewController
        //Here you could do any other UI operations
        if Reachability.isConnectedToNetwork() == true
        {
            print("Connected")
        }
        else
        {
            let controller = UIAlertController(title: "No Internet Detected", message: "This app requires an Internet connection", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                    return
                }
                
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                }
            }
            controller.addAction(settingsAction)
            controller.addAction(ok)
            
            present(controller, animated: true, completion: nil)
        }
        
    }


}
