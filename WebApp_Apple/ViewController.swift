//
//  ViewController.swift
//  WebApp_Apple
//
//  Created by Aryan Sharma on 08/12/16.
//  Copyright © 2016 Aryan Sharma. All rights reserved.
//

import UIKit
import Toaster
import SystemConfiguration

class ViewController: UIViewController, UIWebViewDelegate,UIGestureRecognizerDelegate, UIScrollViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var clearBtn: UIButton!
    @IBOutlet weak var StopRefreshBtn: UIButton!
    @IBOutlet weak var topBarStackView: UIStackView!
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var incogView: UIView!
    @IBOutlet weak var mainStackView: UIStackView!
    
    
    var firstRun = true
    
    
    
    
   
//    @IBOutlet weak var startUpView: UIView!
    
    var url: NSURL!
    var request: NSURLRequest!
    var searchEngine: String!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        incogView.isHidden = true
        view.layer.cornerRadius = 10
        
        webView.delegate = self
        webView.scrollView.delegate = self
        addressTextField.delegate = self
        
        addressTextField.returnKeyType = .go
        addressTextField.keyboardType = .webSearch
        addressTextField.clearButtonMode = .whileEditing
        
        activityIndicator.isHidden = true
        
        webView.isUserInteractionEnabled = true
        webView.allowsLinkPreview = true
        webView.allowsInlineMediaPlayback = true
        webView.allowsPictureInPictureMediaPlayback = true
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        self.webView.scrollView.panGestureRecognizer.require(toFail: swipeRight)

        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
        self.webView.scrollView.panGestureRecognizer.require(toFail: swipeLeft)
        

        let edgeGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(edgeSwiped))
        edgeGesture.edges = .left
        webView.addGestureRecognizer(edgeGesture)
        
        let tapLockGesture = UITapGestureRecognizer(target: self, action: #selector(tapLock))    
        tapLockGesture.delegate = self
        tapLockGesture.numberOfTapsRequired = 3
        view.addGestureRecognizer(tapLockGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillTerminate), name: NSNotification.Name.UIApplicationWillTerminate, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)

        
        if let search = searchEngine, search != "custom" {
            loadSearch()
        }else{
            addressTextField.becomeFirstResponder()
        }
        
        

    }
    
    //MARK: Tap Gesture Recognition
    
    func edgeSwiped(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        if gestureRecognizer.state == .recognized{
            print("edge")
            clearBtnPressed(Any.self)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func tapLock() {
        print("Tap Lock!!")
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "LockVC")
        self.present(vc, animated: false, completion: nil)
    }
    
    // MARK: application behaviour
    
    func didEnterBackground() {
        print("Background Entered")
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "LockVC")
        self.present(vc, animated: false, completion: nil)
    }
    
    func applicationWillTerminate() {
        clearBtnPressed(Any.self)
    }
    
    func willResignActive() {
        print("application resigned")
        if incogView.isHidden == true {
            print("hide")
            view.bringSubview(toFront: incogView)
            UIView.transition(with: self.view, duration: 0.5, options: .transitionCrossDissolve, animations: {self.incogView.isHidden = false}, completion: nil)
            print(incogView.isHidden)
        }
    }
    
    func didBecomeActive() {
        print("Did become Active")
        if incogView.isHidden == false {
            print("unhide")
            UIView.transition(with: self.view, duration: 0.5, options: .transitionCrossDissolve, animations: {            self.incogView.isHidden = true}, completion: nil)
            view.sendSubview(toBack: incogView)
            print(incogView.isHidden)
        }
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
    }
    
    
    
    
    // MARK: Screen Swipe Gestures
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                print("Swiped right")
                if webView.canGoBack{
                    webView.goBack()
                    removeCurrentToast()
                    Toast(text: "Back", duration: Delay.short).show()
                }else{
                    removeCurrentToast()
                    Toast(text: "Can't go Back Anymore!!", duration: Delay.short).show()
                }
                
            case UISwipeGestureRecognizerDirection.left:
                print("Swiped left")
                if webView.canGoForward {
                    removeCurrentToast()
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
    
    var lastContentOffset: CGPoint!
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        lastContentOffset = scrollView.contentOffset
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if lastContentOffset.y > scrollView.contentOffset.y {
            print("Going up!")
            if topBarStackView.isHidden == true{
                UIView.animate(withDuration: 0.2, animations: {
                    self.topBarStackView.isHidden = false
                })
            }
        } else {
            print("Going down!")
            if topBarStackView.isHidden == false {
                UIView.animate(withDuration: 0.2, animations: {
                    self.topBarStackView.isHidden = true
                })
            }
        }

    }
    
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//            }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if (scrollView.contentOffset.y < -60){
            //reach top
            print("Reach Top")
            webView.reload()
            removeCurrentToast()
            Toast(text: "Refreshing!!", duration: Delay.short).show()
        }
        

//        if scrollView.contentOffset.y >= 0 && targetContentOffset.pointee.y > 0{
//            
//            if targetContentOffset.pointee.y < scrollView.contentOffset.y {
//                print("Going up!")
//                if topBarStackView.isHidden == true{
//                    UIView.animate(withDuration: 0.2, animations: {
//                        self.topBarStackView.isHidden = false
//                    })
//                }
//            } else {
//                print("Going down!")
//                if topBarStackView.isHidden == false {
//                    UIView.animate(withDuration: 0.2, animations: {
//                        self.topBarStackView.isHidden = true
//                    })
//                }
//            }
//        }
        
//        if scrollView.contentOffset.y == 0 && targetContentOffset.pointee.y == 0{
//            if topBarStackView.isHidden == true{
//                UIView.animate(withDuration: 0.2, animations: {
//                    self.topBarStackView.isHidden = false
//                })
//            }
//        }
        
    }
    
    // MARK: URL Processing
    
    func loadSearch() {
        
        if isInternetAvailable() {
            request = NSURLRequest(url: url as URL)
            webView.loadRequest(request as URLRequest)
        }else{
            noInternetConnection()
        }
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
            }else if searchEngine! == "google"{
                searchQuery = "https://www.google.com/search?q="
            }
        }
        if !addUrl.contains("."){
            url = NSURL(string: searchQuery+"\(addUrl.replacingOccurrences(of: " ", with: "+"))")
        }else if !addUrl.contains("https://") || !addUrl.contains("http://"){
            url = NSURL(string: "http://"+"\(addUrl)")
        }else{
            url = NSURL(string: "\(addUrl)")
        }
        
        if isInternetAvailable(), searchQuery != "" {
            request = NSURLRequest(url: url as URL)
            webView.loadRequest(request as URLRequest)
        }else{
            noInternetConnection()
        }

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
        activityIndicator.startAnimating()
        StopRefreshBtn.setImage(nil, for: .normal)
        StopRefreshBtn.setTitle("X", for: .normal)
        StopRefreshBtn.setTitleColor(UIColor.white, for: .normal)
        addressTextField.text = webView.request?.url?.absoluteString
    }
    

    func webViewDidFinishLoad(_ webView: UIWebView) {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        StopRefreshBtn.setTitle(nil, for: .normal)
        StopRefreshBtn.setImage(UIImage(named: "refreshIcon"), for: .normal)
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        StopRefreshBtn.setTitle(nil, for: .normal)
        StopRefreshBtn.setImage(UIImage(named: "refreshIcon"), for: .normal)
    }
    
    // MARK: Buttons
    
    @IBAction func BackBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        print("Back Btn")
    }
    
    
    @IBAction func NavBtnPressed(_ sender: UIButton) {
        print("NavBtn pressed")
        if sender.titleLabel?.text == "<" {
            if webView.canGoBack{
                webView.goBack()
                removeCurrentToast()
                Toast(text: "Back", duration: Delay.short).show()
            }else{
                removeCurrentToast()
                Toast(text: "Can't go Back Anymore!!", duration: Delay.short).show()
            }
        }else {
            if webView.canGoForward {
                removeCurrentToast()
                webView.goForward()
                Toast(text: "Next", duration: Delay.short).show()
            }else{
                removeCurrentToast()
                Toast(text: "Can't go Forward Anymore!!", duration: Delay.short).show()
            }
        }
    }
    
    @IBAction func StopRefreshBtnPressed(_ sender: UIButton) {
        if webView.isLoading{
            webView.stopLoading()
            print("stop")
        } else {
            webView.reload()
            print("reload")
        }
    }
    
    
    @IBAction func HomeBtnPressed(_ sender: UIButton) {
        if let search = searchEngine {
            if search == "google"{
                url = NSURL(string: "https://www.google.com")
            } else if search == "bing" {
                url = NSURL(string: "https://www.bing.com")
            }else if search == "duckduckgo" {
                url = NSURL(string: "https://www.duckduckgo.com")
            }else if search == "custom" {
                url = NSURL(string: "https://www.google.com")
            }
            request = NSURLRequest(url: url as URL)
            webView.loadRequest(request as URLRequest)
        }
    }
    
    
    // MARK: Clear Functions

    func removeCurrentToast() {
        if let currentToast = ToastCenter.default.currentToast {
            currentToast.cancel()
            print("Removed current Toast")
        }
    }
    
    
    @IBAction func clearBtnPressed(_ sender: Any) {
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
     //   self.dismiss(animated: true, completion: nil)

    }
    
    // MARK: Defaults
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    // MARK: Internet Connectivity
    
    func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
    func noInternetConnection() {
        removeCurrentToast()
        Toast(text: "No Internet", duration: Delay.short).show()
    }
    
}

