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
    
    

}
