//
//  OnboardingViewController.swift
//  CurtziOSApp
//
//  Created by George Nyakundi on 23/04/2024.
//

import UIKit

final class OnboardingViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .tertiarySystemGroupedBackground
        title = "Login"
        setupView()
    }
    
    // MARK: - UI Fields
    let usernameField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter your username"
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        return textField
    }()
    
    let passwordField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter your password"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let loginBtn: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .green
        btn.setTitleColor(.black, for: .normal)
        btn.setTitle("Login", for: .normal)
        
        return btn
    }()
    
    @objc func buttonTappedAction() {
//            coordinator?.start()
        }
        
        @objc func textFieldDidChange(_ textField: UITextField) {
//            coordinator?.username = textField.text
        }
    
    private func setupView() {
        view.addSubview(usernameField)
        view.addSubview(passwordField)
        view.addSubview(loginBtn)
        
        loginBtn.addTarget(self, action: #selector(buttonTappedAction), for: .touchUpInside)
        usernameField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        let safeArea = view.safeAreaLayoutGuide
        
        // Activate Constraints
        NSLayoutConstraint.activate([
            // Username text field
            usernameField.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 50),
            usernameField.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            usernameField.heightAnchor.constraint(equalToConstant: 30),
            usernameField.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            usernameField.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            
            passwordField.topAnchor.constraint(equalTo: usernameField.bottomAnchor, constant: 20),
            passwordField.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            passwordField.heightAnchor.constraint(equalToConstant: 30),
            passwordField.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            passwordField.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            
            // BTN
            
            loginBtn.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 40),
            loginBtn.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            loginBtn.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            loginBtn.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            loginBtn.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}
