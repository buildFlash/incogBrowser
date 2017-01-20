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
    
    var connectedToInternet = false
    var isFirstLaunch = UserDefaults.isFirstLaunch()
    var searchEngine: String!

    let vc = ViewController()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.layer.cornerRadius = 10
       
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
    }

    
    func willResignActive() {
//        print("application resigned")
//        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyBoard.instantiateViewController(withIdentifier: "LockVC")
//        self.present(vc, animated: false, completion: nil)
        
    }
    
    @IBAction func unwindToMain(segue:UIStoryboardSegue) {
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

        if let vc = segue.destination as? ViewController {
            if searchEngine == "Google" {
                vc.url = NSURL(string: "https://www.google.com")
                vc.searchEngine = "google"
            }
            
            else if searchEngine == "Bing" {
                vc.url = NSURL(string: "https://www.bing.com")
                vc.searchEngine = "bing"
            }
            
            else if searchEngine == "DuckDuckGo" {
                vc.url = NSURL(string: "https://www.duckduckgo.com")
                vc.searchEngine = "duckduckgo"
            } else {
                vc.url = NSURL(string: "")
                vc.searchEngine = "custom"
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
        searchEngine = "custom"
        performSegue(withIdentifier: "google", sender: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // ViewControllers view ist fully loaded and could present further ViewController
        //Here you could do any other UI operations
        
        if (isFirstLaunch == true) {
            print("first launch segued")
            UIView.setAnimationsEnabled(false)
            performSegue(withIdentifier: "showPageVC", sender: self)
            UIView.setAnimationsEnabled(true)
            isFirstLaunch = false
        }
        
        
//        if connectedToInternet == false {
//            if Reachability.isConnectedToNetwork() == true
//            {
//                print("Connected")
//            }
//            else
//            {
//                let controller = UIAlertController(title: "No Internet Detected", message: "This app requires an Internet connection", preferredStyle: .alert)
//                let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
//                let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
//                    guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
//                        return
//                    }
//                    
//                    if UIApplication.shared.canOpenURL(settingsUrl) {
//                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
//                            print("Settings opened: \(success)") // Prints true
//                        })
//                    }
//                }
//                controller.addAction(settingsAction)
//                controller.addAction(ok)
//                self.connectedToInternet = true
//                present(controller, animated: true, completion: nil)
//            }
//        }

    }
}
