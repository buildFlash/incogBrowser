//
//  WKWebVC.swift
//  IncogNeatOh
//
//  Created by Aryan Sharma on 27/02/17.
//  Copyright © 2017 Aryan Sharma. All rights reserved.
//

import UIKit
import WebKit
import Speech
import FontAwesome_swift
import  Toaster
import SystemConfiguration

class WKWebVC: UIViewController, WKNavigationDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate, UITextFieldDelegate, SFSpeechRecognizerDelegate {
    
    @IBOutlet weak var TopBarStackView: UIView!
    @IBOutlet weak var WKWebViewFrameView: UIView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var clearBtn: UIButton!
    @IBOutlet weak var StopRefreshBtn: UIButton!
    //    @IBOutlet var mainView: UIView!
    @IBOutlet weak var incogView: UIView!
    //    @IBOutlet weak var mainStackView: UIStackView!
    
    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var AddressBarConstraint: NSLayoutConstraint!
    
    var webView: WKWebView!
    var url: NSURL!
    var request: NSURLRequest!
    var searchEngine: String!
    
    var isFirstLoad = true
    var swipeLeft: UISwipeGestureRecognizer!
    var swipeRight: UISwipeGestureRecognizer!
    var isGrantedNotificationAccess:Bool = false
    let defaults = UserDefaults.standard
    var addText: String!

    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-IN"))  //1
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView = WKWebView(frame: self.WKWebViewFrameView.bounds)
        webView.navigationDelegate = self
        
        WKWebViewFrameView.addSubview(webView)
//        self.view.sendSubview(toBack: webView)

        micButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 15)
        micButton.setTitle(String.fontAwesomeIcon(name: .microphone), for: .normal)
        micButton.isEnabled = false
        
        speechRecognizer?.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in  //4
            
            var isButtonEnabled = false
            
            switch authStatus {  //5
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            
            OperationQueue.main.addOperation() {
                self.micButton.isEnabled = isButtonEnabled
            }
        }
        
        
        incogView.isHidden = true
        view.layer.cornerRadius = 10
        isFirstLoad = true
        
        refreshBtn()
        //        AddressBarConstraint.constant -= 28
        
        webView.scrollView.delegate = self
        addressTextField.delegate = self
        
        addressTextField.returnKeyType = .go
        addressTextField.keyboardType = .webSearch
        addressTextField.clearButtonMode = .whileEditing
        
        activityIndicator.isHidden = true
        
        webView.isUserInteractionEnabled = true
        webView.allowsLinkPreview = true
        
        swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        
        swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        
        
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
        
        loadUrl(addUrl: addText!)

        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

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
            if TopBarStackView.isHidden == true{
                UIView.animate(withDuration: 0.2, animations: {
                    self.TopBarStackView.isHidden = false
                })
            }
        } else {
            print("Going down!")
            if TopBarStackView.isHidden == false {
                UIView.animate(withDuration: 0.2, animations: {
                    self.TopBarStackView.isHidden = true
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
    }
    
    // MARK: URL Processing
    
    func loadSearch() {
        print("called loadSearch")
        if isInternetAvailable() {
            request = NSURLRequest(url: url as URL)
            webView.load(request as URLRequest)
        }else{
            noInternetConnection()
        }
        //        addressTextField.text = webView.request?.url?.absoluteString
    }
    
    func loadUrl(addUrl: String) {
        var newUrl = ""
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
        if !addUrl.contains(".") {
            url = NSURL(string: searchQuery+"\(addUrl.replacingOccurrences(of: " ", with: "+"))")
        }else if addUrl.contains(".") && addUrl.contains(" ") {
            print(addUrl)
            newUrl = addUrl.replacingOccurrences(of: ".", with: "+")
            print(newUrl)
            newUrl = newUrl.replacingOccurrences(of: " ", with: "+")
            print(newUrl)
            url = NSURL(string: searchQuery+newUrl)
            print(url)
        }else if !addUrl.contains("https://") || !addUrl.contains("http://"){
            url = NSURL(string: "http://"+"\(addUrl)")
        } else {
            url = NSURL(string: "\(addUrl)")
        }
        
        if isInternetAvailable(), searchQuery != "" {
            request = NSURLRequest(url: url as URL)
            webView.load(request as URLRequest)
//            webView.load(request as URLRequest)
            //            addressTextField.text = webView.request?.url?.absoluteString
        }else{
            noInternetConnection()
        }
        addressTextField.text = webView.url?.absoluteString
    }
    
    
    // MARK: Delegates
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        loadUrl(addUrl: addressTextField.text!)
        addressTextField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        addressTextField.selectedTextRange = addressTextField.textRange(from: addressTextField.beginningOfDocument, to: addressTextField.endOfDocument)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print(error.localizedDescription)
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        AddressBarConstraint.constant -= 28
        UIView.animate(withDuration: 0.5) {
            self.addressTextField.layoutIfNeeded()
        }
        refreshBtn()
        addressTextField.text = webView.url?.absoluteString
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("Start to load")
        AddressBarConstraint.constant += 28
        UIView.animate(withDuration: 0.3) {
            self.addressTextField.layoutIfNeeded()
        }
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        stopBtn()
        addressTextField.text = webView.url?.absoluteString
        
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("finish to load")
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        AddressBarConstraint.constant -= 28
        UIView.animate(withDuration: 0.3) {
            self.addressTextField.layoutIfNeeded()
        }
        refreshBtn()
        addressTextField.text = webView.url?.absoluteString
    }
    
    // MARK: Buttons
    
    @IBAction func micBtnPressed(_ sender: UIButton) {
        print("mic btn pressed")
        
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            micButton.isEnabled = false
            micButton.setTitle(String.fontAwesomeIcon(name: .microphone), for: .normal)
            //            microphoneButton.setTitle("Start Recording", for: .normal)
        } else {
            startRecording()
            micButton.setTitle(String.fontAwesomeIcon(name: .stopCircleO), for: .normal)
            
            //            microphoneButton.setTitle("Stop Recording", for: .normal)
        }
    }
    
    func startRecording() {
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else {
            fatalError("Audio engine has no input node")
        }
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil {
                //                print(result?.bestTranscription.formattedString)
                self.addressTextField.text = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                //                print(result?.bestTranscription.formattedString)
                if result != nil {
                    self.loadUrl(addUrl: (result?.bestTranscription.formattedString)!)
                }
                
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.micButton.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
            print("audio engine started")
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
        //        addressTextField.text = "Say something, I'm listening!"
        
    }
    
    func stopBtn() {
        StopRefreshBtn.setTitle(String.fontAwesomeIcon(name: .timesCircleO), for: .normal)
        StopRefreshBtn.setTitleColor(UIColor.white, for: .normal)
    }
    
    func refreshBtn() {
        StopRefreshBtn.titleLabel?.font = UIFont.fontAwesome(ofSize: 17)
        StopRefreshBtn.setTitle(String.fontAwesomeIcon(name: .refresh), for: .normal)
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
            webView.load(request as URLRequest)
            addressTextField.text = webView.url?.absoluteString
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
        
        webView.evaluateJavaScript("localStorage.clear();", completionHandler: nil)
        let cookieJar = HTTPCookieStorage.shared
        for cookie in cookieJar.cookies! {
            cookieJar.deleteCookie(cookie)
        }
        UserDefaults.standard.synchronize()
        
        removeCurrentToast()
        Toast(text: "History Cleared. Phew!!", duration: Delay.short).show()
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
