//
//  ViewController.swift
//  Fabflix
//
//  Created by Tongjie Wang on 5/25/20.
//  Copyright © 2020 wangtongjie. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var logInFailedPrompt: UILabel!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var logInButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!
    lazy var initialLogInButtonBottomConstraintConstant: CGFloat = {
        return self.logInButtonBottomConstraint.constant
    }()
    
    static let loginAPIEndPoint = "login"

    // MARK: - UI Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailField.delegate = self
        emailField.tag = 0
        
        passwordField.delegate = self
        passwordField.tag = 1
        
        logInFailedPrompt.text = ""
        logInButton.setTitle("Logging in...", for: .disabled)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === emailField {
            textField.resignFirstResponder()
            passwordField.becomeFirstResponder()
        } else if textField === passwordField {
            passwordField.resignFirstResponder()
            login()
        }
        return false
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        logInButtonBottomConstraint.constant = initialLogInButtonBottomConstraintConstant + keyboardSize.height
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        guard ((notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil else {
            return
        }
        
        logInButtonBottomConstraint.constant = initialLogInButtonBottomConstraintConstant
    }
    
    @IBAction func onViewTap(_ recognizer: UITapGestureRecognizer) {
        guard recognizer === tapGestureRecognizer else { return }
        if recognizer.state == .ended {
            view.endEditing(true)
        }
    }
    
    @IBAction func onLogInButtonTap(_ button: UIButton) {
        guard button === logInButton else { return }
        login()
    }
    
    // MARK: - Login and Its Handler
    
    func login() {
        if emailField.text!.count == 0 || passwordField.text!.count == 0 {
            updateUIOnLogInFailed(because: "Please enter both email and password")
            return
        }
        
        view.endEditing(true)
        logInButton.isEnabled = false
        
        let url = URL(string: baseURL + LogInViewController.loginAPIEndPoint)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let postString = "email=\(emailField.text!)&password=\(passwordField.text!)&type=customer"
        request.httpBody = postString.data(using: .utf8)
        request.setValue("Dalvik", forHTTPHeaderField: "User-Agent")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error)
                self.updateUIOnLogInFailed(because: "Failed to log in (\(error.localizedDescription))")
                return
            }
            
            if let response = response as? HTTPURLResponse {
                if response.statusCode != 200 {
                    self.updateUIOnLogInFailed(because: "Failed to log in (statusCode=\(response.statusCode))")
                    return
                }
            } else {
                self.updateUIOnLogInFailed(because: "Failed to log in (not HTTPURLResponse)")
                return
            }
            
            do {
                let json = try JSONDecoder().decode(LogInResponse.self, from: data!)
                if json.status != "success" {
                    print(json)
                    self.updateUIOnLogInFailed(because: json.message ?? json.errorMessage ?? "Failed to log in due to unknown reason")
                    return
                }
                
                DispatchQueue.main.async {
                    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                    let movieListViewController = storyBoard.instantiateViewController(identifier: "movieListNavigationController")
                    movieListViewController.modalPresentationStyle = .fullScreen
                    self.present(movieListViewController, animated: true, completion: nil)
                }
            } catch let decodingError as DecodingError {
                print(decodingError)
                self.updateUIOnLogInFailed(because: "Error while decoding response")
                return
            } catch let unknownError {
                print(unknownError)
                self.updateUIOnLogInFailed(because: "Failed to log in due to unknown reason")
                return
            }
        }
        task.resume()
    }
    
    func updateUIOnLogInFailed(because reason: String) {
        DispatchQueue.main.async {
            self.logInButton.isEnabled = true
            self.logInFailedPrompt.text = reason
            self.passwordField.text = ""
        }
    }
}

