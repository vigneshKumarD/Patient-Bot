//
//  PatientWebView.swift
//  Patient Triage
//
//  Created by Vignesh Kumar on 01/08/17.
//  Copyright © 2017 Google Inc. All rights reserved.
//

import UIKit


extension String {
    var condensedWhitespace: String {
        let components = self.components(separatedBy: NSCharacterSet.whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.joined(separator: "")
    }
}

class PatientWebView: UIViewController {

    @IBOutlet weak var webview: UIWebView!
   public var searchText = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        print(searchText)
        let strng   = "https://patient.info/search.asp?searchterm=\(searchText)&searchcoll=All"
      
        let  url1  = URL.init(string: strng.condensedWhitespace)!
    
        let req = URLRequest.init(url:url1 as URL)
        
        webview.loadRequest(req)
    
       
    }

    @IBAction func doneButton(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
   

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
