//
//  FinalPageVC.swift
//  WebApp_Apple
//
//  Created by Aryan Sharma on 30/12/16.
//  Copyright © 2016 Aryan Sharma. All rights reserved.
//

import UIKit

class FinalPageVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func nextBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
      //  performSegue(withIdentifier: "showInitialVC", sender: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
