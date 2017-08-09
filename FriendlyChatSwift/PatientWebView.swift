//
//  PatientWebView.swift
//  Patient Triage
//
//  Created by Vignesh Kumar on 01/08/17.
//  Copyright © 2017 Google Inc. All rights reserved.
//

import UIKit

class PatientWebView: UIViewController {

    @IBOutlet weak var webview: UIWebView!
   public var searchText : String!
    override func viewDidLoad() {
        super.viewDidLoad()
        print(searchText)
        
        let st : NSString! = NSString.init(string: "https://patient.info/search.asp?searchterm=\(searchText!)&searchcoll=All")
        
        let patientUrl : URL = URL.init(string: st as String)!
        
        webview.loadRequest(URLRequest(url: patientUrl))
    
       
    }

    @IBAction func doneButton(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
   

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
