//
//  ViewController.swift
//  WebApp_Apple
//
//  Created by Aryan Sharma on 08/12/16.
//  Copyright © 2016 Aryan Sharma. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIWebViewDelegate,UIGestureRecognizerDelegate, UIScrollViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var addressTextField: UITextField!
    
    var url: NSURL!
    var request: NSURLRequest!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        webView.delegate = self
        webView.scrollView.delegate = self
        addressTextField.delegate = self
        
        addressTextField.returnKeyType = .go
        addressTextField.keyboardType = .webSearch
        addressTextField.clearButtonMode = .whileEditing
        
        activityIndicator.isHidden = false
        
        url = NSURL(string: "https://www.google.com")
        request = NSURLRequest(url: url as URL)
        webView.loadRequest(request as URLRequest)
        
        webView.isUserInteractionEnabled = true
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        self.webView.scrollView.panGestureRecognizer.require(toFail: swipeRight)

        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
        self.webView.scrollView.panGestureRecognizer.require(toFail: swipeLeft)

    }
    
    func loadUrl(addUrl: String) {
        print("called")
        if !addUrl.contains("."){
            url = NSURL(string: "https://www.google.com/search?q="+"\(addUrl.replacingOccurrences(of: " ", with: "+"))")
        }else{
            url = NSURL(string: "http://"+"\(addUrl)")
        }
        
        request = NSURLRequest(url: url as URL)
        webView.loadRequest(request as URLRequest)
        addressTextField.text = url.absoluteString
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        addressTextField.resignFirstResponder()
        loadUrl(addUrl: addressTextField.text!)
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        addressTextField.selectedTextRange = addressTextField.textRange(from: addressTextField.beginningOfDocument, to: addressTextField.endOfDocument)
    }

    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                print("Swiped right")
                if webView.canGoBack{
                    webView.goBack()
                }
           
            case UISwipeGestureRecognizerDirection.left:
                print("Swiped left")
                if webView.canGoForward {
                    webView.goForward()
                }
            default:
                break
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if (scrollView.contentOffset.y < 0){
            //reach top
            print("Reach Top")
            webView.reload()
        }
    }

    

}

