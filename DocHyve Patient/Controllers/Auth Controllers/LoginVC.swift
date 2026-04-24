//
//  LoginVC.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 21/02/2024.
//

import UIKit
import FacebookLogin
import GoogleSignIn
import AuthenticationServices
class LoginVC: ParentViewController {
    
    //MARK: Outlets
    @IBOutlet weak var lblWelcome: UILabel!
    @IBOutlet weak var lblDochyve: UILabel!
    @IBOutlet weak var lblSigninContinue: UILabel!
    @IBOutlet weak var lblDontHaveAccount: UILabel!
    @IBOutlet weak var lblCreateAccount: UILabel!
    @IBOutlet weak var lblLessMinute: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var txtEmail: AuthTextField!
    @IBOutlet weak var lblPassword: UILabel!
    @IBOutlet weak var txtPassword: AuthTextField!
    @IBOutlet weak var btnForgetPassword: UIButton!
    @IBOutlet weak var btnSignin: UIButton!
    @IBOutlet weak var lblLoginWith: UILabel!
    @IBOutlet weak var lblGoogle: UILabel!
    @IBOutlet weak var lblFacebook: UILabel!
    @IBOutlet var btnAppleLogin: UIButton!
    @IBOutlet var lblAppleLogin: UILabel!
    
    
    
    //MARK: Variable
    var validator: Validator!
    
    
    //MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        validateTextField()
    }
    
    //MARK: Functions
    func validateTextField() {
        validator = Validator(withView: self.view)
        validator.add(textField: txtEmail, rules: [.minLength(1),.regex(.email)])
        validator.add(textField: txtPassword, rules: [.minLength(1)])
        txtEmail.errorText =  Constants.TextFieldError.invalidEmail
        txtEmail.emptyErrorText = Constants.TextFieldError.emptyString
        txtPassword.emptyErrorText = Constants.TextFieldError.emptyString
    }
    func callApi(){
        showLoadingView("")
        LoginService().login(email:txtEmail.text!,password:txtPassword.text!,completion: { (success) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                if let data = success as? LoginResponseDataModel
                {
                    if data.userData.signupStep == 3{
                        let patientFullName = data.userData.firstName + " " + data.userData.lastName
                        UserDefaults.standard.set(patientFullName, forKey: "userName")
                        
                        let nextVC = LoginVC.getDashboardVC()
                        self.navigationController?.pushViewController(nextVC, animated: true)
                        if UserDefaults.standard.string(forKey: "fcmToken") != nil{
                            sendDeviceToken()
                        }
                    }else if data.userData.signupStep == 2{
                        let nextVC = self.getCreateProfileVC()
                        nextVC.userId = data.userData.id
                        self.navigationController?.pushViewController(nextVC, animated: true)
                    }else {
                        let nextVC = self.getVerifyEmailVC()
                        nextVC.email = self.txtEmail.text!
                        nextVC.userId = data.userData.id
                        nextVC.isFromForgetPassword = false
                        self.navigationController?.pushViewController(nextVC, animated: true)
                    }
                    
                }
                else if let inactiveData = success as? LoginInActiveResponseModel{
                    if inactiveData.userInfo.signup_step == 3{
                        let nextVC = self.getReactivateEmailVC()
                        nextVC.email = self.txtEmail.text!
                        self.navigationController?.pushViewController(nextVC, animated: true)
                    }else{
                        let nextVC = self.getVerifyEmailVC()
                        nextVC.email = self.txtEmail.text!
                        nextVC.userId = inactiveData.userInfo.id
                        nextVC.isFromForgetPassword = false
                        self.navigationController?.pushViewController(nextVC, animated: true)
                    }
                }
            }
        }) { (faliure) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                self.showAlertView(message: faliure ?? Constants.GenericStrings.somethingWentWrong)
            }
        }
        
    }
    
    
    func socialLoginCall(parameter: [String: Any]){
        
        showLoadingView("")
        SocialLoginService().login(parameters:parameter,completion: { (success) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                if let data = success as? LoginResponseDataModel
                {
                    let patientFullName = data.userData.firstName + " " + data.userData.lastName
                    UserDefaults.standard.set(patientFullName, forKey: "userName")
                    
                    let nextVC = LoginVC.getDashboardVC()
                    self.navigationController?.pushViewController(nextVC, animated: true)
                    if UserDefaults.standard.string(forKey: "fcmToken") != nil{
                        sendDeviceToken()
                    }
                }
                
            }
        }) { (faliure) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                self.showAlertView(message: faliure ?? Constants.GenericStrings.somethingWentWrong)
            }
        }
        
    }
    
    func getUserProfile(token: AccessToken?) {

        let graphRequest = GraphRequest(
            graphPath: "me",
            parameters: [
                "fields": "id,first_name,last_name,name,email,picture.type(large)"
            ],
            tokenString: token?.tokenString,
            version: nil,
            httpMethod: .get
        )

        graphRequest.start { _, result, error in

            if let error = error {
                print("Graph API error:", error.localizedDescription)
                return
            }

            guard let data = result as? [String: Any] else {
                print("Invalid Graph API response")
                return
            }

            let userIdentifier = data["id"] as? String ?? ""
            let firstName = data["first_name"] as? String ?? ""
            let lastName = data["last_name"] as? String ?? ""
            let name = data["name"] as? String ?? ""
            let email = data["email"] as? String ?? "-"
            let accessToken = token?.tokenString ?? ""

            let image = "https://graph.facebook.com/\(userIdentifier)/picture?type=large"

            let param: [String: Any] = [
                "provider": "facebook",
                "user_identifier": userIdentifier,
                "email": email,
                "name": name,
                "first_name": firstName,
                "last_name": lastName,
                "token": accessToken,
                "image": image
            ]

            self.socialLoginCall(parameter: param)
        }
    }
    
    func completeFacebookLogout() {
        let loginManager = LoginManager()
        loginManager.logOut()
        AccessToken.current = nil
        Profile.current = nil
        
        // Clear Safari cookies to ensure a fresh login screen
        let cookieStorage = HTTPCookieStorage.shared
        if let cookies = cookieStorage.cookies(for: URL(string: "https://facebook.com/")!) {
            for cookie in cookies {
                cookieStorage.deleteCookie(cookie)
            }
        }
        
        if let cookies = cookieStorage.cookies(for: URL(string: "https://www.facebook.com/")!) {
            for cookie in cookies {
                cookieStorage.deleteCookie(cookie)
            }
        }
    }
    func googleLogin(presentingVC: UIViewController) {
        // read CLIENT_ID from GoogleService-Info.plist
        guard let clientID = Bundle.main.object(forInfoDictionaryKey: "CLIENT_ID") as? String else {
            print("❌ CLIENT_ID not found in Info.plist")
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC) { signInResult, error in
            if let error = error {
                print("Google Sign-In error:", error.localizedDescription)
                return
            }
            guard let user = signInResult?.user else { return }
            let userid = user.userID ?? ""
            let idToken = user.idToken?.tokenString ?? ""
            let accessToken = user.accessToken.tokenString
            let email = user.profile?.email
            let name = user.profile?.name ?? ""
            let image = user.profile?.imageURL(withDimension: 100)?.absoluteString ?? ""
            
            let parts = name.split(separator: " ")

            let firstName = String(parts.first!)
            let lastName = String(parts.last!)
            
            let param: [String: Any] = [
                "provider": "google",
                "user_identifier": userid,
                "email": email ?? "-",
                "name": name,
                "first_name": firstName,
                "last_name": lastName,
                "token": accessToken ,
                "image": image ,
            ]
            self.socialLoginCall(parameter: param)
            
        }
    }
    
    func sendDeviceToken(){
      
        let deviceToken  = UserDefaults.standard.string(forKey: "fcmToken") ?? ""
              
        let param: [String: Any] = [
            "device_token": deviceToken ,
            "device_type": "ios",
            "platform": "ios_patient_app",
        ]
        
        //showLoadingView("")
        AddDataService().addData(parameters:param,endPoint:Constants.URLs.addDeviceToken,completion: { (success) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                if success is GeneralResponseModel
                {
                    
                }

            }
        }) { (faliure) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                self.showAlertView(message: faliure ?? Constants.GenericStrings.somethingWentWrong)
            }
        }
        
    }
    //MARK: ButtonActions
    @IBAction func btnForgetPasswordAction(_ sender: Any) {
        let nextVC = getForgetPasswordVC()
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    @IBAction func btnHideShowAction(_ sender: UIButton) {
        txtPassword.isSecureTextEntry.toggle()
        let imageName = txtPassword.isSecureTextEntry ? "iconhide" : "iconshow"
        sender.setImage(UIImage(named: imageName), for: .normal)
        
    }
    @IBAction func btnSigninAction(_ sender: Any) {
        self.view.endEditing(true)
        validator.validateNow { [weak self] valid in
            guard let strongSelf = self else { return }
            if valid {
                strongSelf.callApi()
            }
        }
    }
    @IBAction func btnCreateAccountAction(_ sender: Any) {
        let nextVC = getRegisterVC()
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    @IBAction func btnGoogleAction(_ sender: Any) {
        googleLogin(presentingVC: self)
    }
    @IBAction func btnFacebookAction(_ sender: Any) {
        
        // Logout first to force new login
        completeFacebookLogout()
        
        let loginManager = LoginManager()
        loginManager.logIn(
            permissions: ["public_profile", "email"],
            from: self
        ) { result, error in

            if let error = error {
                print("Facebook Login Error:", error.localizedDescription)
                return
            }

            guard let result = result else { return }

            if result.isCancelled {
                print("Facebook login cancelled")
                return
            }

            guard let token = result.token else {
                print("No access token received")
                return
            }

            print("Logged in successfully")
            self.getUserProfile(token: token)
        }

    }
    @IBAction func btnAppleLoginAction(_ sender: UIButton) {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        
        request.requestedScopes = [.fullName, .email]
        
        let authController = ASAuthorizationController(authorizationRequests: [request])
        authController.delegate = self
        authController.presentationContextProvider = self
        authController.performRequests()
    }
    
}

extension LoginVC: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

extension LoginVC: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
        
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            let userID = credential.user
            let email = credential.email
            let fullName = credential.fullName

            let firstName = fullName?.givenName
            let lastName = fullName?.familyName

            var tokenString = ""
            if let tokenData = credential.identityToken {
                tokenString = String(data: tokenData, encoding: .utf8) ?? ""
            }

            // Base params (always included)
            var param: [String: Any] = [
                "provider": "apple",
                "user_identifier": userID,
                "token": tokenString
            ]

            // Only add optional values if they exist
            if let email = email {
                param["email"] = email
            }

            if let firstName = firstName {
                param["first_name"] = firstName
            }

            if let lastName = lastName {
                param["last_name"] = lastName
            }

            if let firstName = firstName, let lastName = lastName {
                param["name"] = "\(firstName) \(lastName)"
            } else if let firstName = firstName {
                param["name"] = firstName
            }
            
            self.socialLoginCall(parameter: param)
            
            // Save userID in Keychain for future login
        }
    }
    
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithError error: Error) {
        print("Apple Login Failed: \(error.localizedDescription)")
    }
}

