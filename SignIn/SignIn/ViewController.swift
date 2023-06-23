//
//  ViewController.swift
//  SignIn
//
//  Created by STS326-BOOBALAKRISHNAN M on 12/05/23.
//

import UIKit
import GoogleSignIn
import Firebase

class ViewController: UIViewController {

    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var signOutBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func googleSignOutBtnAction(_ sender: Any) {
        
        let message = "This is normal text.\nBold Title:\n This is normal text"
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)

        let attributedText = NSMutableAttributedString(string: "Bold Title:", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold)])
        alertController.setValue(message, forKey: "attributedMessage")

        self.present(alertController, animated: true, completion: nil)
        
//        let auth = Auth.auth()
//
//        do {
//            try auth.signOut()
//
//            signOutBtn.isHidden = true
//            signInBtn.isHidden = false
//        }
//        catch let error as NSError {
//            print(error)
//        }
    }
    
    @IBAction func googleSignInBtnAction(_ sender: Any) {
        
        let htmlStr = "The business <b> Test </b> is locked"
        
        showAlertWithAttributedStringWithCompletionHandler(alertTitle: "", alertMessage: "", attributedString: htmlStr.htmlAttributedString().with(font: UIFont.systemFont(ofSize: 15))) { UIAlertAction in
            
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: self) {result, error in

            guard error == nil else {

                return
            }
            if let user = result?.user
            {
                if let idtoken = user.idToken?.tokenString
                {
                    let credential = GoogleAuthProvider.credential(withIDToken: idtoken, accessToken: user.accessToken.tokenString)

                    Auth.auth().signIn(with: credential) { [self]result, error in
                        print(result)
                        print(error)

                        signOutBtn.isHidden = false
                        signInBtn.isHidden = true
                    }
                }




            }

        }
    }
    
    func showAlertWithAttributedStringWithCompletionHandler(alertTitle: String,alertMessage: String, attributedString: NSAttributedString? = nil, completionHandlerForOk : @escaping (UIAlertAction) -> Void)
    {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle:
                                            .alert)
        
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        
        paragraphStyle.alignment = .center
        
        var messageText = NSMutableAttributedString()
        
        if let attirbutedStr = attributedString{
            messageText = NSMutableAttributedString(attributedString: attirbutedStr)

            let attributes = [
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
//                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),
                NSAttributedString.Key.foregroundColor: UIColor.black
            ]
            messageText.addAttributes(attributes, range: NSRange(location: 0, length: messageText.length))
        }
        else {
            messageText = NSMutableAttributedString(
                string: alertMessage,
                attributes: [
                    NSAttributedString.Key.paragraphStyle: paragraphStyle,
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),
                    NSAttributedString.Key.foregroundColor: UIColor.black
                ]
            )
        }
        alert.setValue(messageText, forKey: "attributedTitle")

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: completionHandlerForOk))

//        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}

extension String
{
    var htmlToAttributedString: NSAttributedString?
    {
         guard let data = data(using: .utf8) else { return NSAttributedString() }
         do
         {
             return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
         }
         catch
         {
              return NSAttributedString()
         }
    }
    
    func htmlAttributedString() -> NSMutableAttributedString {
        
        guard let data = self.data(using: String.Encoding.utf8, allowLossyConversion: false)
        else { return NSMutableAttributedString() }
        
        guard let formattedString = try? NSMutableAttributedString(data: data,
                                                                   options: [.documentType: NSAttributedString.DocumentType.html,
                                                                             .characterEncoding: String.Encoding.utf8.rawValue],
                                                                   documentAttributes: nil )
                
        else { return NSMutableAttributedString() }
        
        return formattedString
    }
}

extension NSMutableAttributedString {

    func with(font: UIFont) -> NSMutableAttributedString {
        self.enumerateAttribute(NSMutableAttributedString.Key.font, in: NSMakeRange(0, self.length), options: .longestEffectiveRangeNotRequired, using: { (value, range, stop) in
            let originalFont = value as! UIFont
            if let newFont = applyTraitsFromFont(originalFont, to: font) {
                self.addAttribute(NSAttributedString.Key.font, value: newFont, range: range)
            }
        })
        return self
    }

    func applyTraitsFromFont(_ f1: UIFont, to f2: UIFont) -> UIFont? {
        let originalTrait = f1.fontDescriptor.symbolicTraits

        if originalTrait.contains(.traitBold) {
            var traits = f2.fontDescriptor.symbolicTraits
            traits.insert(.traitBold)
            if let fd = f2.fontDescriptor.withSymbolicTraits(traits) {
                return UIFont.init(descriptor: fd, size: 0)
            }
        }
        return f2
    }
}
