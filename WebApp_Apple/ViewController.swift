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
import UserNotifications

class ViewController: UIViewController, UIWebViewDelegate,UIGestureRecognizerDelegate, UIScrollViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var clearBtn: UIButton!
    @IBOutlet weak var StopRefreshBtn: UIButton!
    @IBOutlet weak var topBarStackView: UIView!
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var incogView: UIView!
    @IBOutlet weak var mainStackView: UIStackView!
    
    @IBOutlet weak var AddressBarConstraint: NSLayoutConstraint!
    
    var isFirstLoad = true
    var swipeLeft: UISwipeGestureRecognizer!
    var swipeRight: UISwipeGestureRecognizer!
    var isGrantedNotificationAccess:Bool = false
    let defaults = UserDefaults.standard

    
    
   
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
        isFirstLoad = true
        
        refreshBtn()
//        AddressBarConstraint.constant -= 28
        
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
        
        swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
//        self.view.addGestureRecognizer(swipeRight)
//        self.webView.scrollView.panGestureRecognizer.require(toFail: swipeRight)

        swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
//        self.view.addGestureRecognizer(swipeLeft)
//        self.webView.scrollView.panGestureRecognizer.require(toFail: swipeLeft)
        

        let edgeGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(edgeSwiped))
        edgeGesture.edges = .left
        webView.addGestureRecognizer(edgeGesture)
        
        let rightEdgeGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(edgeSwiped))
        rightEdgeGesture.edges = .right
        webView.addGestureRecognizer(rightEdgeGesture)
        
        let tapLockGesture = UITapGestureRecognizer(target: self, action: #selector(tapLock))    
        tapLockGesture.delegate = self
        tapLockGesture.numberOfTapsRequired = 3
        webView.addGestureRecognizer(tapLockGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillTerminate), name: NSNotification.Name.UIApplicationWillTerminate, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)

        
        if let search = searchEngine, search != "custom" {
            loadSearch()
        }else{
            addressTextField.becomeFirstResponder()
            AddressBarConstraint.constant -= 28
        }
        
        
//        UNUserNotificationCenter.current().requestAuthorization(
//            options: [.alert,.sound,.badge],
//            completionHandler: { (granted,error) in
//                self.isGrantedNotificationAccess = granted
//        })
//        userNotifs()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        defaults.set(1, forKey: "count")
    }
    
//    func userNotifs() {
//        if isGrantedNotificationAccess {
//            let content = UNMutableNotificationContent()
//            content.title = "Quit App"
//            content.subtitle = "Clear Everything"
//            content.categoryIdentifier = "message"
//        
//        
//        //Set the trigger of the notification -- here a timer.
//        let trigger = UNTimeIntervalNotificationTrigger(
//            timeInterval: 1.0,
//            repeats: false)
//            
//            
//        //Set the request for the notification from the above
//        let request = UNNotificationRequest(
//            identifier: "10.second.message",
//            content: content,
//            trigger: trigger
//        )
//        
//        //Add the notification to the currnet notification center
//        UNUserNotificationCenter.current().add(
//            request, withCompletionHandler: nil)
//        }
//    }
    
    //MARK: Tap Gesture Recognition
    
    func edgeSwiped(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        if gestureRecognizer.state == .recognized{
            print("edge")
            if gestureRecognizer.edges == .right{
                print("Swiped right")
                if webView.canGoForward{
                    webView.goForward()
                    removeCurrentToast()
                    Toast(text: "Back", duration: Delay.short).show()
                }else{
                    removeCurrentToast()
                    Toast(text: "Can't go Forward Anymore!!", duration: Delay.short).show()
                }
            }
            if gestureRecognizer.edges == .left{
                print("Swiped right")
                if webView.canGoBack{
                    webView.goBack()
                    removeCurrentToast()
                    Toast(text: "Back", duration: Delay.short).show()
                }else{
                    removeCurrentToast()
                    Toast(text: "Can't go Back Anymore!!", duration: Delay.short).show()
                }
            }
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
    
    
    // MARK: Screen Swipe Gestures
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
//    var zoomLevel: CGFloat!
//    var zoomLevelAfterZoomedOut: CGFloat!
//    
//    func scrollViewDidZoom(_ scrollView: UIScrollView) {
//        print(scrollView.zoomScale)
//
//        if scrollView.isZooming {
//            zoomLevel = scrollView.zoomScale
//        } else {
//            zoomLevelAfterZoomedOut = scrollView.zoomScale
//        }
//    }
//    
//    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
//        print("didEndZooming")
//        print(scrollView.zoomScale)
//        if let zoomCheck = zoomLevel{
//            if zoomCheck > 1.0{
//                view?.removeGestureRecognizer(swipeLeft)
//                print("removed Left")
//                view?.removeGestureRecognizer(swipeRight)
//                print("removed Right")
//            }
//        }
//        
//        if let zoomCheck = zoomLevelAfterZoomedOut{
//            print(zoomCheck)
//            if(zoomLevel * zoomCheck == 1.0) {
//                view?.addGestureRecognizer(swipeRight)
//                print("added right")
//                view?.addGestureRecognizer(swipeLeft)
//                print("added Left")
//            }
//        }
//    }
    
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
        print("called loadSearch")
        if isInternetAvailable() {
            request = NSURLRequest(url: url as URL)
            webView.loadRequest(request as URLRequest)
        }else{
            noInternetConnection()
        }
//        addressTextField.text = webView.request?.url?.absoluteString
    }
    
    func loadUrl(addUrl: String) {
        print("called loadUrl")
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
//            addressTextField.text = webView.request?.url?.absoluteString
        }else{
            noInternetConnection()
        }
//        addressTextField.text = webView.request?.url?.absoluteString
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
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        addressTextField.text = webView.request?.url?.absoluteString
        return true
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        if !isFirstLoad{
            AddressBarConstraint.constant += 28
            UIView.animate(withDuration: 0.3) {
                self.addressTextField.layoutIfNeeded()
            }
        }else {
                isFirstLoad = false
        }
    
        stopBtn()
        addressTextField.text = webView.request?.url?.absoluteString
    }
    

    func webViewDidFinishLoad(_ webView: UIWebView) {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        AddressBarConstraint.constant -= 28
        UIView.animate(withDuration: 0.3) {
            self.addressTextField.layoutIfNeeded()
        }
        refreshBtn()
        addressTextField.text = webView.request?.url?.absoluteString
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        AddressBarConstraint.constant -= 28
        UIView.animate(withDuration: 0.5) {
            self.addressTextField.layoutIfNeeded()
        }
        refreshBtn()
        addressTextField.text = webView.request?.url?.absoluteString
    }
    
    // MARK: Buttons
    
    func stopBtn() {
        StopRefreshBtn.setImage(nil, for: .normal)
        StopRefreshBtn.setTitle("X", for: .normal)
        StopRefreshBtn.setTitleColor(UIColor.black, for: .normal)
    }
    
    func refreshBtn() {
        StopRefreshBtn.setTitle(nil, for: .normal)
        StopRefreshBtn.setImage(UIImage(named: "refreshIcon"), for: .normal)
    }
    
    @IBAction func BackBtnPressed(_ sender: Any) {
        clearBtnPressed(Any.self)
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
            addressTextField.text = webView.request?.url?.absoluteString
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

