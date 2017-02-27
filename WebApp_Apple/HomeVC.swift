//
//  HomeVC.swift
//  WebApp_Apple
//
//  Created by Aryan Sharma on 24/02/17.
//  Copyright © 2017 Aryan Sharma. All rights reserved.
//

import UIKit
import Speech
import FontAwesome_swift

class HomeVC: UIViewController, SFSpeechRecognizerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var addressBarTextField: UITextField!
    @IBOutlet weak var micBtn: UIButton!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var LogoImageConstraint: NSLayoutConstraint!
    @IBOutlet weak var MicButtonConstraint: NSLayoutConstraint!
    @IBOutlet weak var LabelConstraint: NSLayoutConstraint!
    @IBOutlet weak var SegControlConstraint: NSLayoutConstraint!


    
    var selectedControl = "ddg"
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-IN"))  //1
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    override func viewDidLoad() {
        super.viewDidLoad()
        micBtn.titleLabel?.font = UIFont.fontAwesome(ofSize: 15)
        micBtn.setTitle(String.fontAwesomeIcon(name: .microphone), for: .normal)

        micBtn.isEnabled = false
        
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
                self.micBtn.isEnabled = isButtonEnabled
            }
        }
        
        addressBarTextField.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func searchSegmentedControl(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            selectedControl = "ddg"
        } else if sender.selectedSegmentIndex == 1 {
            selectedControl = "google"
        } else if sender.selectedSegmentIndex == 2 {
            selectedControl = "bing"
        } else if sender.selectedSegmentIndex == 3 {
            selectedControl = "custom"
        }
    }


    @IBAction func goBtnPressed(_ sender: Any) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            micBtn.isEnabled = false
            micBtn.setTitle(String.fontAwesomeIcon(name: .microphone), for: .normal)
        }
        
        if addressBarTextField.text != nil {
            performSegue(withIdentifier: "homeToWKWebVC", sender: nil)
        }
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            micBtn.isEnabled = true
        } else {
            micBtn.isEnabled = false
        }
    }

    
    @IBAction func micBtnPressed(_ sender: Any) {
        print("mic btn pressed")
        
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            micBtn.isEnabled = false
            micBtn.setTitle(String.fontAwesomeIcon(name: .microphone), for: .normal)
        } else {
            startRecording()
            micBtn.setTitle(String.fontAwesomeIcon(name: .stopCircleO), for: .normal)
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
                    self.addressBarTextField.text = result?.bestTranscription.formattedString
                    isFinal = (result?.isFinal)!
                }
                
                if error != nil || isFinal {
                    self.audioEngine.stop()
                    //                print(result?.bestTranscription.formattedString)
                    if result != nil {
                        self.goBtnPressed(Any.self)
                    }
                    
                    inputNode.removeTap(onBus: 0)
                    
                    self.recognitionRequest = nil
                    self.recognitionTask = nil
                    
                    self.micBtn.isEnabled = true
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
            
            
        }
    
    // MARK: Delegates
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        addressBarTextField.resignFirstResponder()
        goBtnPressed(Any.self)
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        addressBarTextField.selectedTextRange = addressBarTextField.textRange(from: addressBarTextField.beginningOfDocument, to: addressBarTextField.endOfDocument)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        addressBarTextField.resignFirstResponder()
    }

    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if let vc = segue.destination as? WKWebVC {
            vc.addText = "\(addressBarTextField.text!)"
            if selectedControl == "google" {
                vc.url = NSURL(string: "https://www.google.com")
                vc.searchEngine = "google"
            }
                
            else if selectedControl == "bing" {
                vc.url = NSURL(string: "https://www.bing.com")
                vc.searchEngine = "bing"
            }
                
            else if selectedControl == "ddg" {
                vc.url = NSURL(string: "https://www.duckduckgo.com")
                vc.searchEngine = "duckduckgo"
            }
            
            else if selectedControl == "custom" {
                vc.url = NSURL(string: "")
                vc.searchEngine = "custom"
            }
        }
    }
    
//    func keyboardWillShow(notification: NSNotification) {
//        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//            
//            UIView.animate(withDuration: 0.2, animations: {
//                self.view.frame.origin.y -= keyboardSize.height - 85
//                self.label.isHidden = true
//            })
//        }
//    }
//    
//    func keyboardWillHide(notification: NSNotification) {
//        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//            UIView.animate(withDuration: 0.2, animations: {
//                self.view.frame.origin.y += keyboardSize.height - 85
//                self.label.isHidden = false
//            })
//
//            
//        }
//    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height - 85
//                self.label.isHidden = true
                self.LogoImageConstraint.constant -= 60
                self.MicButtonConstraint.constant -= 12
                self.LabelConstraint.constant -= 30
                self.SegControlConstraint.constant -= 30
                UIView.animate(withDuration: 0.2, animations: {
//                    self.LogoImageConstraint.constant -= 50
                    print("keyboard will show called")
                    self.view.layoutIfNeeded()

                  })
            }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height - 85
//                self.label.isHidden = false
                self.LogoImageConstraint.constant += 60
                self.MicButtonConstraint.constant += 12
                self.LabelConstraint.constant += 30
                self.SegControlConstraint.constant += 30
                UIView.animate(withDuration: 0.2, animations: {
//                    self.LogoImageConstraint.constant += 50
                    print("keyboard will hide called")
                    self.view.layoutIfNeeded()
                })
            }
        }
    
    
    }
}
