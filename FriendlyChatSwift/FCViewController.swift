//
//  Copyright (c) 2015 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Photos
import UIKit
import AVFoundation
import Speech


import Firebase
import GoogleSignIn
import GoogleMobileAds
import ApiAI


/**
 * AdMob ad unit IDs are not currently stored inside the google-services.plist file. Developers
 * using AdMob can store them as custom values in another plist, or simply use constants. Note that
 * these ad units are configured to return only test ads, and should not be used outside this sample.
 */
let kBannerAdUnitID = "ca-app-pub-3940256099942544/2934735716"

@available(iOS 10.0, *)
@objc(FCViewController)
class FCViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,
    UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,SFSpeechRecognizerDelegate, InviteDelegate {

    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var btnVoice: UIButton!
    
    @IBOutlet weak var constHBottomLayout: NSLayoutConstraint!
  // Instance variables
  @IBOutlet weak var textField: UITextField!
  @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var imgSiriGif: UIImageView!
   
    @IBOutlet var consBottomOptions: NSLayoutConstraint!
    @IBOutlet var constHBottomView: NSLayoutConstraint!
    
    @IBOutlet var btnSendOptions: UIButton!
    @IBOutlet var btnOptions1: UIButton!
    @IBOutlet var btnOptions2: UIButton!
    @IBOutlet var btnOptions3: UIButton!
    @IBOutlet var btnOptions4: UIButton!
    @IBOutlet var btnNoneOfThese: UIButton!
    
    @IBOutlet weak var btnSendAllOptions: UIButton!
    var buttonOptionsArray = NSMutableArray()
   var optionsSelectedArray = NSMutableArray()
    
    
  var ref: DatabaseReference!
  var messages: [DataSnapshot]! = []
  var msglength: NSNumber = 400
  var apiAi = ApiAI()
    
  var cell = StackTableViewCell()
  var multipleOptionsArray = NSArray()
    var multipleOptionvalue : [String] = [""]
    var listOfOptions  : [String?] = [""]
     var singleListOptions  : [String?] = [""]
    
  var storedOffsets = [Int: CGFloat]()
    
  fileprivate var _refHandle: DatabaseHandle?

  var storageRef: StorageReference!
  var remoteConfig: RemoteConfig!
  var bottomoffset :CGPoint!
    //Speech
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))!
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    
  @IBOutlet weak var banner: GADBannerView!
  @IBOutlet weak var clientTable: UITableView!

  override func viewDidLoad() {
    super.viewDidLoad()

    
    buttonOptionsArray = [self.btnOptions1,self.btnOptions2,self.btnOptions3,self.btnOptions4]
    headerView.layer.shadowColor = UIColor.lightGray.cgColor
    clientTable.rowHeight = UITableViewAutomaticDimension
   
    clientTable.allowsSelection = false
    configureDatabase()
    configureStorage()
    configureRemoteConfig()
    fetchConfig()
    loadAd()
    logViewLoaded()
    

    //Speech
    self.requestSpeechCalls()
    
  }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
    NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
    NotificationCenter.default.addObserver(self, selector:#selector(self.keyboardNotification(notification:)) , name:NSNotification.Name.UIKeyboardWillHide, object: nil);
        
    }
    
   
    func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
               
                self.constHBottomLayout.constant = 70.0
            }
            else {
                
                if (self.clientTable.contentSize.height)+30 > (self.clientTable.bounds.size.height)
                {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                        let numberOfSections = self.clientTable.numberOfSections
                        let numberOfRows = self.clientTable.numberOfRows(inSection: numberOfSections-1)
                        
                        if numberOfRows > 0 {
                            let indexPath = IndexPath(row: numberOfRows-1, section: (numberOfSections-1))
                            self.clientTable.scrollToRow(at: indexPath, at: .bottom, animated: true)
                        }
                    }
//                    //Scrolls to bottom
//                     bottomoffset = CGPoint(x: 0, y: (self.clientTable.contentSize.height+(endFrame?.size.height)!-80) - (self.clientTable.bounds.size.height) )
//                    self.clientTable.setContentOffset(bottomoffset, animated: false)
                }
                 self.constHBottomLayout.constant = endFrame?.size.height ?? 70.0
            }
            
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
    
    
  deinit {
    if let refHandle = _refHandle  {
      self.ref.child("messages").removeObserver(withHandle: refHandle)
     NotificationCenter.default.removeObserver(self);
    }
  }

  func configureDatabase() {
    ref = Database.database().reference()
    // Listen for new messages in the Firebase database
    _refHandle = self.ref.child("messages").observe(.childAdded, with: { [weak self] (snapshot) -> Void in
      guard let strongSelf = self else { return }
      strongSelf.messages.append(snapshot)
      strongSelf.clientTable.insertRows(at: [IndexPath(row: strongSelf.messages.count-1, section: 0)], with: .automatic)
        
        if (self?.clientTable.contentSize.height)!+30 > (self?.clientTable.bounds.size.height)!
        {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                let numberOfSections = self?.clientTable.numberOfSections
                let numberOfRows = self?.clientTable.numberOfRows(inSection: numberOfSections!-1)
                
                if numberOfRows! > 0 {
                    let indexPath = IndexPath(row: numberOfRows!-1, section: (numberOfSections!-1))
                    self?.clientTable.scrollToRow(at: indexPath, at: .bottom, animated: false)
                }
            }
            
        }
        
//        if (self?.clientTable.contentSize.height)! > (self?.clientTable.bounds.size.height)!
//        {
//            //Scrolls to bottom
//            if (self?.bottomoffset != nil){
//                
//           let bottomoffse :CGPoint! = CGPoint(x: 0, y: (self!.clientTable.contentSize.height - self!.clientTable.bounds.height))
//            self?.clientTable.setContentOffset(bottomoffse, animated: false)
//            }
//        }
    })
  }

    

  func configureStorage() {
    storageRef = Storage.storage().reference()
  }

  func configureRemoteConfig() {
    remoteConfig = RemoteConfig.remoteConfig()
    // Create Remote Config Setting to enable developer mode.
    // Fetching configs from the server is normally limited to 5 requests per hour.
    // Enabling developer mode allows many more requests to be made per hour, so developers
    // can test different config values during development.
    let remoteConfigSettings = RemoteConfigSettings(developerModeEnabled: true)
    remoteConfig.configSettings = remoteConfigSettings!
  }

  func fetchConfig() {
    var expirationDuration: Double = 3600
    // If in developer mode cacheExpiration is set to 0 so each fetch will retrieve values from
    // the server.
    if self.remoteConfig.configSettings.isDeveloperModeEnabled {
      expirationDuration = 0
    }

    // cacheExpirationSeconds is set to cacheExpiration here, indicating that any previously
    // fetched and cached config would be considered expired because it would have been fetched
    // more than cacheExpiration seconds ago. Thus the next fetch would go to the server unless
    // throttling is in progress. The default expiration duration is 43200 (12 hours).
    remoteConfig.fetch(withExpirationDuration: expirationDuration) { [weak self] (status, error) in
      if status == .success {
        print("Config fetched!")
        guard let strongSelf = self else { return }
        strongSelf.remoteConfig.activateFetched()
        let friendlyMsgLength = strongSelf.remoteConfig["friendly_msg_length"]
        if friendlyMsgLength.source != .static {
          strongSelf.msglength = friendlyMsgLength.numberValue!
          print("Friendly msg length config: \(strongSelf.msglength)")
        }
      } else {
        print("Config not fetched")
        if let error = error {
          print("Error \(error)")
        }
      }
    }
  }

  @IBAction func didPressFreshConfig(_ sender: AnyObject) {
    fetchConfig()
  }

  @IBAction func didSendMessage(_ sender: UIButton) {
   // _ = textFieldShouldReturn(textField)
    
    
    let data = [Constants.MessageFields.text: textField.text]
        sendMessage(withData: data as! [String : String])
    }

  @IBAction func didPressCrash(_ sender: AnyObject) {
    FirebaseCrashMessage("Cause Crash button clicked")
    fatalError()
  }

  @IBAction func inviteTapped(_ sender: AnyObject) {
    if let invite = Invites.inviteDialog() {
      invite.setInviteDelegate(self)

      // NOTE: You must have the App Store ID set in your developer console project
      // in order for invitations to successfully be sent.

      // A message hint for the dialog. Note this manifests differently depending on the
      // received invitation type. For example, in an email invite this appears as the subject.
      invite.setMessage("Try this out!\n -\(Auth.auth().currentUser?.displayName ?? "")")
      // Title for the dialog, this is what the user sees before sending the invites.
      invite.setTitle("Patient Bot")
      invite.setDeepLink("app_url")
      invite.setCallToActionText("Install!")
      invite.setCustomImage("https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png")
      invite.open()
    }
  }

  func inviteFinished(withInvitations invitationIds: [String], error: Error?) {
    if let error = error {
        print("Failed: \(error.localizedDescription)")
    } else {
      print("Invitations sent")
    }
  }

  func logViewLoaded() {
    FirebaseCrashMessage("View loaded")
  }

  func loadAd() {
    self.banner.adUnitID = kBannerAdUnitID
    self.banner.rootViewController = self
    self.banner.load(GADRequest())
  }
    
    func buttonAction(sender: UIButton!) {
        print("Button tapped")
    }
    

  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    guard let text = textField.text else { return true }

    let newLength = text.characters.count + string.characters.count - range.length
    return newLength <= self.msglength.intValue // Bool
  }

  // UITableViewDataSource protocol methods
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    
      return UITableViewAutomaticDimension

        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let tableViewCell = cell as? StackTableViewCell else { return }
        
        tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
        tableViewCell.collectionViewOffset = storedOffsets[indexPath.row] ?? 0
    }
    
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return messages.count
  }

    
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    // Dequeue cell
    
    let cell : ChatTableViewCell = self.clientTable .dequeueReusableCell(withIdentifier: "ClientCell", for: indexPath) as! ChatTableViewCell
    

    // Unpack message from Firebase DataSnapshot
    let messageSnapshot: DataSnapshot! = self.messages[indexPath.row]
    guard let message = messageSnapshot.value as? [String:String] else { return cell }
    //try

    
    let name = message[Constants.MessageFields.name] ?? ""
    
    
    if let imageURL = message[Constants.MessageFields.imageURL] {
      if imageURL.hasPrefix("gs://") {
        Storage.storage().reference(forURL: imageURL).getData(maxSize: INT64_MAX) {(data, error) in
          if let error = error {
            print("Error downloading: \(error)")
            return
          }
          DispatchQueue.main.async {
            //cell.imageView?.image = UIImage.init(data: data!)
            cell.imgUserImage.image = UIImage.init(data: data!)
            cell.setNeedsLayout()
          }
        }
      } else if let URL = URL(string: imageURL), let data = try? Data(contentsOf: URL) {
       // cell.imageView?.image = UIImage.init(data: data)
        cell.imgUserImage.image = UIImage.init(data: data)
      }
    //  cell.textLabel?.text = "sent by: \(name)"
        cell.lblChatText.text = "sent by: \(name)"
    }
//    else if  message[Constants.MessageFields.parameters] != nil {
//        
//    
//        self.cell = self.clientTable.dequeueReusableCell(withIdentifier: "stackCell", for: indexPath) as! StackTableViewCell
//        
//        return self.cell
//        
//        }
        
    else {
    
        //API.AI bot  response
      let text = message[Constants.MessageFields.text] ?? ""
        
       if let textSpeech = message[Constants.MessageFields.speech] {
        
        cell.lblChatText.text = "\(textSpeech ) "
        cell.lblChatText.textColor = UIColor.black
        cell.lblChatText.textAlignment = NSTextAlignment.right
        cell.imgUserImage.image = nil
        cell.lblChatText.backgroundColor = UIColor.white
        }
        else{
        
        cell.lblChatText.text = " \(text)"
        cell.lblChatText.textColor = UIColor.black
        cell.lblChatText.textAlignment = NSTextAlignment.left
         cell.lblChatText.backgroundColor = UIColor.init(colorLiteralRed: 197.0/255.0, green: 224.0/255.0, blue: 159.0/255.0, alpha: 1.0)
        cell.imgUserImage.image = UIImage(named: "ic_account_circle")

            if let photoURL = message[Constants.MessageFields.photoURL], let URL = URL(string: photoURL),
                let data = try? Data(contentsOf: URL) {
              //  cell.imageView?.image = UIImage(data: data)
                cell.imgUserImage.image = UIImage(data: data)
                cell.imgUserImage.layer.cornerRadius = 10.0
                cell.imgUserImage.layer.cornerRadius = cell.imgUserImage.frame.size.width/2
                cell.imgUserImage.clipsToBounds = true
            
            }

        }
        
        cell.lblChatText.layer.cornerRadius = 10.0
        cell.lblChatText.clipsToBounds = true
        
         }
    return cell
    

  }

  // UITextViewDelegate protocol methods
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    guard textField.text != nil else { return true }
    view.endEditing(true)

//    let data = [Constants.MessageFields.text: text]
//    sendMessage(withData: data)
    return true
  }

  func sendMessage(withData data: [String: String]) {
    
    var mdata = data
    mdata[Constants.MessageFields.name] = Auth.auth().currentUser?.displayName
    if let photoURL = Auth.auth().currentUser?.photoURL {
      mdata[Constants.MessageFields.photoURL] = photoURL.absoluteString
    }
    // Push data to Firebase Database
    self.ref.child("messages").childByAutoId().setValue(mdata)
    
    self.requestForApiAi(dataValue: mdata as NSDictionary)
    textField.text = nil
    
  }
//MARK: - SPEECH API
    
  func requestSpeechCalls() {
        
        btnVoice.isEnabled = false
        speechRecognizer.delegate = self
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            var isButtonEnabled = false
            
            switch authStatus {
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
                self.btnVoice.isEnabled = isButtonEnabled
            }
        }

    }
    
    
    //MARK: - API.AI
    func requestForApiAi(dataValue : NSDictionary)
    {
        
        apiAi = ApiAI.shared()!
        let textRequest : AITextRequest = self.apiAi.textRequest()
        textRequest.query = [dataValue.value(forKey:"text")]

        textRequest.setCompletionBlockSuccess({ (request, response) -> Void in
            if let responseReceived = response {

                
        let responseDic = responseReceived as! NSDictionary
        var id: NSDictionary
        id = responseDic.value(forKey: "result") as! NSDictionary
        
            let responseFulfillment : NSDictionary! = id.value(forKey: "fulfillment") as! NSDictionary
            let responseSpeech  = responseFulfillment.value(forKey: "speech") as! String
           // print(responseSpeech)
                
                let st = "0"
            //MARK:TODO
                if st == "1" {
                    
                    self.narrateTheText(text: responseSpeech)
                }
                
                
                let requestToPass : NSMutableDictionary = ["speech":responseSpeech]
               
                let metaData : NSDictionary! = id.value(forKey: "metadata") as! NSDictionary
                _ = metaData.value(forKey:"intentName") ?? ""
                
               
                requestToPass[Constants.MessageFields.name] = Auth.auth().currentUser?.displayName
                
                //Auth.auth().currentUser?.displayName
                // Push data to Firebase Database
                self.ref.child("messages").childByAutoId().setValue(requestToPass)
                //Parameters to pass as array
                
                let parameters : NSDictionary? = id.value(forKey: "parameters") as? NSDictionary
                
                if parameters != nil                {
                let diseaseList : NSArray? = parameters!.value(forKey: "SymptomList") as? NSArray
                let symptomList = diseaseList?[0] as? String
                
                if (parameters?.count)! > 0 {
                    //handle SymptomList and SingleOptionList list
                    if parameters?.value(forKey:"SymptomList") != nil
                    {
                        self.singleListOptions.removeAll()
                        
                        if (parameters?.value(forKey: "SymptomList") is Array<Any>){
                            
                            self.multipleOptionsArray  = parameters?.value(forKey:"SymptomList") as!Array<Any> as NSArray
                            
                            let stringValues = self.multipleOptionsArray.componentsJoined(by: ",")
                            print(stringValues)
                            self.listOfOptions = (symptomList?.components(separatedBy: ","))!
                            
                            
                        }
                        else if(parameters?.value(forKey: "SymptomList") is NSString){
                            
                            let efs : NSString = (parameters?.value(forKey:"SymptomList") as? NSString)!
                            self.multipleOptionvalue = efs.components(separatedBy: ",")
                            
                        
                            self.listOfOptions = self.multipleOptionvalue

                        }
                            
                        //self.multipleOptionsArray  = parameters?.value(forKey:"SymptomList") as!Array<Any> as NSArray
                       
                        
                        self.showOptionView()
                        
                        var iterationCount = 0
                        for item in self.listOfOptions {
                            
                           if iterationCount < 4
                            {
                            let btn : UIButton = self.buttonOptionsArray[iterationCount] as! UIButton
                            iterationCount += 1
                            btn.setTitle(item, for: UIControlState.normal)
                            btn.isHidden =  false
                            }
                            
                        }
                        
                        
                        //
                        self.sendButton.isHidden =  true
                        self.btnSendOptions.isHidden =  false
                        self.btnNoneOfThese.isHidden = false
                        self.btnNoneOfThese.setTitle("None of these", for: UIControlState.normal)
                 
                    }
                    else if parameters?.value(forKey:"SingleOptionList") != nil {
                        
                        self.listOfOptions.removeAll()
                        let SingleOptionList : NSString  = (parameters?.value(forKey:"SingleOptionList") as? NSString)!
                        self.singleListOptions = SingleOptionList.components(separatedBy: ",")
                        
                        
                        //SingleListOptions
                       var iterationCount = 0
                        
                        for item in self.singleListOptions{
                            let btn : UIButton = self.buttonOptionsArray[iterationCount] as! UIButton
                            iterationCount += 1
                            btn.setTitle(item, for: UIControlState.normal)
                            btn.isHidden =  false
                            
                        }
                        
                        self.view.endEditing(true)
                        self.consBottomOptions.constant = -100.0
                        self.textField.isHidden = true
                                              
                        self.btnSendOptions.isHidden = true
                        self.sendButton.isHidden =  true
                        self.btnNoneOfThese.isHidden = true
                        
                    }
      
                    
                    
                    }
                }
                else{
                      self.hideOptionView()
                }
                
                //Custom payload
//           let messages  = responseFulfillment.value(forKey: "messages") as! Array<Any>
//               
//               if messages.count > 1
//                {
//                let payload : NSDictionary! = messages[1] as! NSDictionary
//                let dfjnv = payload.value(forKey: "payload") as! NSDictionary
//                let arrOfValues  = dfjnv.value(forKey: "cars") as!Array<Any>
//                print(arrOfValues)
//                }
           
                
            }
            }, failure: { (request, error) -> Void in
                
                
        });
        
        ApiAI.shared().enqueue(textRequest)
        clientTable.reloadData()
        
    }
    
    
    //Device speak
    func narrateTheText(text: String) {
        let synth = AVSpeechSynthesizer()
        
        do {
            try AVAudioSession.sharedInstance().setCategory(
                AVAudioSessionCategoryPlayback,
                with: AVAudioSessionCategoryOptions.mixWithOthers
            )
            let utterance = AVSpeechUtterance(string: text)
            utterance.rate = AVSpeechUtteranceDefaultSpeechRate
            let lang = "en-US"
            synth.continueSpeaking()
            utterance.voice = AVSpeechSynthesisVoice(language: lang)
            synth.continueSpeaking()
            synth.speak(utterance)
            
            
        } catch {
            print(error)
        }
        
    }
    
    //Animation with color change on UIView
    func changeViewColor(color: UIColor) {
        
        self.view.alpha = 0
        self.view.backgroundColor = color
        UIView.animate(withDuration: 1, animations: {
        self.view.alpha = 1
        }, completion: nil)
    }
    
    //MARK: Voice Processing
    
    @IBAction func btnVoicePressed(_ sender: Any) {
        
        if self.audioEngine.isRunning {
            
            self.audioEngine.stop()
            recognitionRequest?.endAudio()
            btnVoice.isEnabled = false
           
            btnVoice.isHidden = false
            print("NOT listening......")
           // btnVoice.setTitle("Start Recording", for: .normal)
        }
        else {
            
            startRecording()
            print("listening......")
          
        }
        
    }
    

    
    func startRecording() {
        
        if recognitionTask != nil {  //1
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()  //2
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()  //3
        
        guard let inputNode = audioEngine.inputNode else {
            fatalError("Audio engine has no input node")
        }  //4
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        } //5
        
        recognitionRequest.shouldReportPartialResults = true
        //6]
       
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in  //7
            
            var isFinal = false  //8
            
            if result != nil {
                
                let responseText = result?.bestTranscription.formattedString
                //9
                let data = [Constants.MessageFields.text: responseText]
                isFinal = (result?.isFinal)!
                self.sendMessage(withData: data as! [String : String])

            }
            
            if error != nil || isFinal {  //10
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                self.btnVoice.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)  //11
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()  //12
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
//        textView.text = "Say something, I'm listening!"
        
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            btnVoice.isEnabled = true
        } else {
            btnVoice.isEnabled = false
        }
    }


  // MARK: - Image Picker

  @IBAction func didTapAddPhoto(_ sender: AnyObject) {
    let picker = UIImagePickerController()
    picker.delegate = self
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
      picker.sourceType = .camera
    } else {
      picker.sourceType = .photoLibrary
    }

    present(picker, animated: true, completion:nil)
  }

  func imagePickerController(_ picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [String : Any]) {
      picker.dismiss(animated: true, completion:nil)
    guard let uid = Auth.auth().currentUser?.uid else { return }

    // if it's a photo from the library, not an image from the camera
    if let referenceURL = info[UIImagePickerControllerReferenceURL] as? URL {
      let assets = PHAsset.fetchAssets(withALAssetURLs: [referenceURL], options: nil)
      let asset = assets.firstObject
      asset?.requestContentEditingInput(with: nil, completionHandler: { [weak self] (contentEditingInput, info) in
        let imageFile = contentEditingInput?.fullSizeImageURL
        let filePath = "\(uid)/\(Int(Date.timeIntervalSinceReferenceDate * 1000))/\((referenceURL as AnyObject).lastPathComponent!)"
        guard let strongSelf = self else { return }
        strongSelf.storageRef.child(filePath)
          .putFile(from: imageFile!, metadata: nil) { (metadata, error) in
            if let error = error {
              let nsError = error as NSError
              print("Error uploading: \(nsError.localizedDescription)")
              return
            }
            strongSelf.sendMessage(withData: [Constants.MessageFields.imageURL: strongSelf.storageRef.child((metadata?.path)!).description])
          }
      })
    } else {
      guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
      let imageData = UIImageJPEGRepresentation(image, 0.8)
      let imagePath = "\(uid)/\(Int(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
      let metadata = StorageMetadata()
      metadata.contentType = "image/jpeg"
      self.storageRef.child(imagePath)
        .putData(imageData!, metadata: metadata) { [weak self] (metadata, error) in
          if let error = error {
            print("Error uploading: \(error)")
            return
          }
          guard let strongSelf = self else { return }
          strongSelf.sendMessage(withData: [Constants.MessageFields.imageURL: strongSelf.storageRef.child((metadata?.path)!).description])
      }
    }
  }

  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true, completion:nil)
  }

  @IBAction func signOut(_ sender: UIButton) {
    let firebaseAuth = Auth.auth()
    do {
      try firebaseAuth.signOut()
      dismiss(animated: true, completion: nil)
    } catch let signOutError as NSError {
      print ("Error signing out: \(signOutError.localizedDescription)")
    }
  }

  func showAlert(withTitle title: String, message: String) {
    DispatchQueue.main.async {
        let alert = UIAlertController(title: title,
            message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .destructive, handler: nil)
        alert.addAction(dismissAction)
        self.present(alert, animated: true, completion: nil)
    }
  }

  //MARK: Button Actions
    
    
    
    @IBAction func btnSendAllOptions(_ sender: Any) {
        
       hideOptionView()
        
        guard optionsSelectedArray.count > 0 else {
            
            return;
        }
        let swiftArray = optionsSelectedArray as AnyObject as! [String]
        let sortedArray = swiftArray.sorted{ $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
        
        let symptomsToPass = sortedArray.joined(separator: ",")
        print(symptomsToPass)
        
        let data = [Constants.MessageFields.text: symptomsToPass]
        sendMessage(withData: data )
        
        for  btn in self.buttonOptionsArray {
            (btn as! UIButton).isSelected = false
        }
        
    }

    @IBAction func btnOption1Action(_ sender: UIButton) {
        
        
        if (self.listOfOptions.count > 0 && sender.isSelected == false) {
            
            optionsSelectedArray.add(self.listOfOptions[0]!)
            sender.isSelected = true
        }
        else if (self.listOfOptions.count > 0 && sender.isSelected == true){ //Single Options YES/NO
            
            optionsSelectedArray.remove(self.listOfOptions[0]!)
            sender.isSelected = false
            
        }
        else{
               //Single Options YES/NO
                hideOptionView()
                let data = [Constants.MessageFields.text: self.singleListOptions[0]]
                sendMessage(withData: data as! [String : String] )
            
        }
        
    }
        
  
    
    @IBAction func btnOptions2Action(_ sender: UIButton) {
        if (self.listOfOptions.count > 0 && sender.isSelected == false) {
            
            optionsSelectedArray.add(self.listOfOptions[1]!)
             sender.isSelected = true
        }
        else if (self.listOfOptions.count > 0 && sender.isSelected == true){ //Single Options YES/NO
            
            optionsSelectedArray.remove(self.listOfOptions[1]!)
             sender.isSelected = false
            
        }
        else{ //Single Options YES/NO
            
            hideOptionView()
            let data = [Constants.MessageFields.text: self.singleListOptions[1]]
            sendMessage(withData: data as! [String : String] )
            
        }
    }
    
    
    @IBAction func btnOption3Action(_ sender: UIButton) {
        
        if (self.listOfOptions.count > 0 && sender.isSelected == false) {
            
            optionsSelectedArray.add(self.listOfOptions[2]!)
             sender.isSelected = true
        }
        else if (self.listOfOptions.count > 0 && sender.isSelected == true){ //Single Options YES/NO
            
            optionsSelectedArray.remove(self.listOfOptions[2]!)
             sender.isSelected = false
            
        }
    }
    
    @IBAction func btnOption4Action(_ sender: UIButton) {
        
        if (self.listOfOptions.count > 0 && sender.isSelected == false) {
            
            optionsSelectedArray.add(self.listOfOptions[3]!)
             sender.isSelected = true
        }
        else if (self.listOfOptions.count > 0 && sender.isSelected == true){ //Single Options YES/NO
            
            optionsSelectedArray.remove(self.listOfOptions[3]!)
             sender.isSelected = false
            
        }
    }
    
    @IBAction func btnNoneOfTheseAction(_ sender: UIButton) {
        
        
        if self.optionsSelectedArray.count > 0 {
            
            self.optionsSelectedArray.removeAllObjects()

            for  btn in self.buttonOptionsArray {
                (btn as! UIButton).isSelected = false
            }
        }
        
        hideOptionView()
        let data = [Constants.MessageFields.text: "None of These"]
        sendMessage(withData: data )

        
    }
    
    func showOptionView() {
        
        self.view.endEditing(true)
        self.constHBottomLayout.constant = 200.0
        self.consBottomOptions.constant = 0.0
        self.textField.isHidden = true
        self.sendButton.isHidden = true
    }
    
    func hideOptionView()
    {
        
        self.constHBottomLayout.constant = 70.0
        self.consBottomOptions.constant = -200.0
        self.textField.isHidden = false
        self.sendButton.isHidden = false
    }
}



var collectionCell = CollectionViewCell()
var optionsCell = OptionsCollectionCell()

extension FCViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row == 0
        {
             optionsCell = collectionView.dequeueReusableCell(withReuseIdentifier: "optionsCell", for: indexPath) as! OptionsCollectionCell
            
            if multipleOptionsArray.count>0 {

             optionsCell.btnText1.setTitle(self.listOfOptions[0] , for: UIControlState.normal)
             optionsCell.btnText2.setTitle(self.listOfOptions[1] , for: UIControlState.normal)
             optionsCell.btnText3.setTitle(self.listOfOptions[2] , for: UIControlState.normal)
             optionsCell.btnText4.setTitle(self.listOfOptions[3] , for: UIControlState.normal)
             optionsCell.btnText5.setTitle("None of these", for: UIControlState.normal)
                

            
            }
            return optionsCell
            
        }
//        collectionCell  = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! CollectionViewCell
//        
//        collectionCell.btn1.setTitle("Option 1", for: UIControlState.normal)
    
        
//        if indexPath.row == 3
//        {
//            collectionCell.imgView?.isHidden = true
//            
//        }
//        else{
//             collectionCell.imgView?.isHidden = false
//        }
        return collectionCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Collection view at row \(collectionView.tag) selected index path \(indexPath)")
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
      
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        if collectionCell.isKind(of:OptionsCollectionCell.self)
        {
        return CGSize.init(width: optionsCell.frame.size.width, height: 175.0)
        }
        else{
            return CGSize.init(width: collectionCell.frame.size.width, height: collectionCell.frame.size.height)
        }
    }
    
    
}


