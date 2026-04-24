//
//  SplashVC.swift
//  DocHyve
//
//  Created by MacBook Pro on 03/10/2023.
//

import UIKit

class SplashVC: ParentViewController {
    
    //MARK: Outlets
    
    //MARK: Variable
    
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
      
        
        if Reachability.isConnectedToNetwork(){
            DispatchQueue.main.asyncAfter(deadline: .now() + 2 ){
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.setLandingScreen()
            }
           
        }else{
            self.showAlertView(message: Constants.GenericStrings.internetNotFound)
        }
    }
    
    //MARK: Functions
    
    
    //MARK: ButtonActions

}
