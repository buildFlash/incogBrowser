//
//  ViewController.swift
//  WebApp_Apple
//
//  Created by Aryan Sharma on 08/12/16.
//  Copyright © 2016 Aryan Sharma. All rights reserved.
//

import UIKit
import Toaster

class ViewController: UIViewController, UIWebViewDelegate,UIGestureRecognizerDelegate, UIScrollViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var clearBtn: UIButton!
    @IBOutlet weak var camouflageView: UIView!
    
   
//    @IBOutlet weak var startUpView: UIView!
    
    var url: NSURL!
    var request: NSURLRequest!
    var segueUsed: String!
    var searchEngine: String!
    
    @IBOutlet var mainView: UIView!

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        camouflageView.isHidden = true
        webView.delegate = self
        webView.scrollView.delegate = self
        addressTextField.delegate = self
        
        addressTextField.returnKeyType = .go
        addressTextField.keyboardType = .webSearch
        addressTextField.clearButtonMode = .whileEditing
        
        if let segue = segueUsed, segue == "google" {
            loadSearch()
        }else{
            addressTextField.becomeFirstResponder()
        }
        
        activityIndicator.isHidden = true
        
        webView.isUserInteractionEnabled = true
        webView.allowsLinkPreview = true
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        self.webView.scrollView.panGestureRecognizer.require(toFail: swipeRight)

        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
        self.webView.scrollView.panGestureRecognizer.require(toFail: swipeLeft)
        
        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(screenEdgeSwiped))
        edgePan.edges = .left
        view.addGestureRecognizer(edgePan)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tripleTap))
        tap.numberOfTapsRequired = 3
        view.addGestureRecognizer(tap)

        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)

    }
    
    func tripleTap() {
        if camouflageView.isHidden {
            showAnimateCamouflageView()
        }else {
           hideAnimateCamouflageView()
        }
    }
    
    // MARK: application behaviour
    
    func didEnterBackground() {
        print("Entered Background")
    }
    
    
    func willEnterForeground() {
        print("Will enter foreground")
        hideAnimateCamouflageView()
    }
    
    func willResignActive() {
        print("application resigned")
        showAnimateCamouflageView()
        //camouflageView.isHidden = false
    }
    
    // MARK: Animations
    
    func hideAnimateCamouflageView() {
        UIView.animate(withDuration: 0.3, delay: 0, options:UIViewAnimationOptions.transitionCrossDissolve, animations: {
            self.camouflageView.alpha = 0
        }, completion: { finished in
            self.camouflageView.isHidden = true
        })
    }
    
    func showAnimateCamouflageView() {
        UIView.transition(with: camouflageView, duration: 0.3, options: .transitionCrossDissolve, animations: {() -> Void in
            self.camouflageView.alpha = 1
            self.camouflageView.isHidden = false
        }, completion: { _ in })
    }
    
    // MARK: Screen Swipe Gestures
    
    func screenEdgeSwiped(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        if recognizer.state == .recognized {
            print("Screen edge swiped!")
            clearEverything()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                print("Swiped right")
                if webView.canGoBack{
                    webView.goBack()
                    Toast(text: "Back", duration: Delay.short).show()
                }else{
                    removeCurrentToast()
                    Toast(text: "Can't go Back Anymore!!", duration: Delay.short).show()
                }
                
            case UISwipeGestureRecognizerDirection.left:
                print("Swiped left")
                if webView.canGoForward {
                    webView.goForward()
                    Toast(text: "Next", duration: Delay.short).show()
                }else{
                    removeCurrentToast()
                    Toast(text: "Can't go Forward Anymore!!", duration: Delay.short).show()
                }
            default:
                break
            }
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if (scrollView.contentOffset.y < -60){
            //reach top
            print("Reach Top")
            webView.reload()
            Toast(text: "Refreshing!!", duration: Delay.short).show()
        }
    }
    
    // MARK: URL Processing
    
    func loadSearch() {
        request = NSURLRequest(url: url as URL)
        webView.loadRequest(request as URLRequest)
    }
    
    func loadUrl(addUrl: String) {
        print("called")
        var searchQuery = "https://www.google.com/search?q="
        if let _ = searchEngine{
            if searchEngine! == "bing"{
                searchQuery = "https://www.bing.com/search?q="
            }
            else if searchEngine! == "duckduckgo"{
                searchQuery = "https://duckduckgo.com/?q="
            }
        }
        if !addUrl.contains("."){
            url = NSURL(string: searchQuery+"\(addUrl.replacingOccurrences(of: " ", with: "+"))")
        }else if !addUrl.contains("https://") || !addUrl.contains("http://"){
            url = NSURL(string: "http://"+"\(addUrl)")
        }else{
            url = NSURL(string: "\(addUrl)")
        }
        
        request = NSURLRequest(url: url as URL)
        webView.loadRequest(request as URLRequest)
    }
    
    
    // MARK: TextField Delegates
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        addressTextField.resignFirstResponder()
        loadUrl(addUrl: addressTextField.text!)
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        addressTextField.selectedTextRange = addressTextField.textRange(from: addressTextField.beginningOfDocument, to: addressTextField.endOfDocument)
    }
    
    // MARK: WebView Delegates
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        activityIndicator.isHidden = false
        clearBtn.isHidden = true
        activityIndicator.startAnimating()
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        clearBtn.isHidden = false
        addressTextField.text = webView.request?.url?.absoluteString
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    // MARK: Clear Functions
    
    func clearEverything() {
        print("cleared")
        URLCache.shared.removeAllCachedResponses()
        URLCache.shared.diskCapacity = 0
        URLCache.shared.memoryCapacity = 0
        
        webView.stringByEvaluatingJavaScript(from: "localStorage.clear();")
        let cookieJar = HTTPCookieStorage.shared
        for cookie in cookieJar.cookies! {
            cookieJar.deleteCookie(cookie)
        }
        UserDefaults.standard.synchronize()
        
        removeCurrentToast()
        Toast(text: "History Cleared. Phew!!", duration: Delay.short).show()
    }
    
    func removeCurrentToast() {
        if let currentToast = ToastCenter.default.currentToast {
            currentToast.cancel()
        }
    }

    @IBAction func clearBtnPressed(_ sender: Any) {
        clearEverything()
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Defaults
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

