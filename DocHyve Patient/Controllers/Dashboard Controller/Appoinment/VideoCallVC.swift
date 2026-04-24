//
//  VideoCallVC.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 13/04/2026.
//

import UIKit
//import JitsiMeetSDK
class VideoCallVC: UIViewController {
   // var jitsiView: JitsiMeetView!
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Do any additional setup after loading the view.
//        startCall()
//    }
//    
//
//    func startCall() {
//        
//        let options = JitsiMeetConferenceOptions.fromBuilder { builder in
//            builder.serverURL = URL(string: "https://meet.dochyve.com") //meet.jit.si
//            builder.room = "call_64C35ACE-FEE6-4F49-B78A-4E1F6E36FEFF"
//            builder.setFeatureFlag("lobby.enabled", withBoolean: false)
//            builder.setFeatureFlag("call-integration.enabled", withBoolean: false)
//            builder.setFeatureFlag("pip.enabled", withBoolean: false)
//        }
//
//        jitsiView = JitsiMeetView(frame: self.view.bounds)
//        jitsiView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        
//        // 🔥 IMPORTANT FIX
//        jitsiView.delegate = self
//        
//        view.addSubview(jitsiView)
//
//        jitsiView.join(options)
//    }

}
//extension VideoCallVC:JitsiMeetViewDelegate{
//    func conferenceJoined(_ data: [AnyHashable : Any]!) {
//          print("Conference Joined")
//      }
//
//      func conferenceTerminated(_ data: [AnyHashable : Any]!) {
//          print("Conference Ended")
//          DispatchQueue.main.async {
//                self.jitsiView?.leave()
//                self.jitsiView?.removeFromSuperview()
//                self.jitsiView = nil
//            }
//      }
//}
