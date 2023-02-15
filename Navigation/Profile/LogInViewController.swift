//
//  LoginViewController.swift
//  Navigation
//
//  Created by Евгений Стафеев on 15.11.2022.
//

import UIKit

class LogInViewController: UIViewController {
    
    var loginDelegate: LoginViewControllerDelegate?
    
    private let currentUserService = CurrentUserService()
    private let testUserService = TestUserService()
    private let brutForceService = BrutForceService()
    
    private let notificationCenter = NotificationCenter.default
    
    private let scrollView: UIScrollView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIScrollView())
    
    private let contentView: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIView())
    
    private let logoImage: UIImageView = {
        let logoImage = UIImageView()
        logoImage.translatesAutoresizingMaskIntoConstraints = false
        logoImage.image = UIImage(named: "logo")
        logoImage.clipsToBounds = true
        return logoImage
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 0.5
        stackView.layer.borderWidth = 0.5
        stackView.layer.cornerRadius = 10
        stackView.backgroundColor = .lightGray
        stackView.clipsToBounds = true
        stackView.layer.borderColor = UIColor.lightGray.cgColor
        return stackView
    }()
    
    private lazy var userLoginTextField: UITextField = {
        let userLoginTextField = UITextField()
        userLoginTextField.translatesAutoresizingMaskIntoConstraints = false
        userLoginTextField.indent(size: 10)
        userLoginTextField.placeholder = "Login"
        userLoginTextField.textColor = .black
        userLoginTextField.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        userLoginTextField.autocapitalizationType = .none
        userLoginTextField.backgroundColor = .systemGray6
        userLoginTextField.delegate = self
        return userLoginTextField
    }()
    
    private lazy var getPassButton: CustomButton = {
        let getPassButton = CustomButton(title: "Подобрать пароль", titleColor: .white)
        getPassButton.clipsToBounds = true
        getPassButton.setBackgroundImage(#imageLiteral(resourceName: "blue_pixel"), for: .normal)
        getPassButton.layer.cornerRadius = 10
        return getPassButton
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .black
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()
    
    private lazy var userPasswordTextField: UITextField = {
        let userPasswordTextField = UITextField()
        userPasswordTextField.translatesAutoresizingMaskIntoConstraints = false
        userPasswordTextField.indent(size: 10)
        userPasswordTextField.placeholder = "Password"
        userPasswordTextField.isSecureTextEntry = true
        userPasswordTextField.textColor = .black
        userPasswordTextField.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        userPasswordTextField.backgroundColor = .systemGray6
        userPasswordTextField.delegate = self
        return userPasswordTextField
    }()
    
    private lazy var logInButton: UIButton = {
        let logInButton = UIButton()
        let colorButton = UIColor(patternImage: UIImage(named: "blue_pixel.png")!)
        logInButton.backgroundColor = colorButton
        logInButton.backgroundColor = .blue
        logInButton.translatesAutoresizingMaskIntoConstraints = false
        logInButton.setTitle("Log In", for: .normal)
        logInButton.layer.cornerRadius = 10
        logInButton.setTitleColor(UIColor.white, for: .normal)
        logInButton.backgroundColor?.withAlphaComponent(1)
        
        if logInButton.isSelected || logInButton.isHighlighted || logInButton.isEnabled == false {
            logInButton.backgroundColor?.withAlphaComponent(0.8)
        }
        logInButton.addTarget(self, action: #selector(logInButtonAction), for: .touchUpInside)
        return logInButton
    }()
    
   
    
    @objc private func logInButtonAction() {
        
#if DEBUG
        let user = currentUserService.userNew
#else
        let user = testUserService.testUser
#endif
        
        guard userLoginTextField.text == user.login, userPasswordTextField.text == user.password else {
            let alert = UIAlertController(title: "Ошибка", message: "Нет данных", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        let profileVC = ProfileViewController()
        self.navigationController?.pushViewController(profileVC, animated: false)
    }
    
    private func passButton() {
        getPassButton.action = {
            self.userPasswordTextField.isSecureTextEntry = true
            self.userPasswordTextField.text = "123"
            let queue = DispatchQueue(label: "ios-homework-9", attributes: .concurrent)
            let workItem = DispatchWorkItem {
                self.brutForceService.bruteForce(passwordToUnlock: "123")
            }
            self.activityIndicator.startAnimating()
            queue.async(execute: workItem)
            workItem.notify(queue: .main) {
                self.userPasswordTextField.isSecureTextEntry = false
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        notificationCenter.addObserver(self, selector: #selector(keyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        notificationCenter.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
      
    @objc private func keyboardShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            scrollView.contentInset.bottom = keyboardSize.height
            scrollView.verticalScrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        }
    }
    
    @objc private func keyboardHide() {
        scrollView.contentInset = .zero
        scrollView.verticalScrollIndicatorInsets = .zero
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
    }
    
    private func setupLayout() {
        view.addSubview(scrollView)
        
        scrollView.addSubview(getPassButton)
        userPasswordTextField.addSubview(activityIndicator)
        

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            getPassButton.topAnchor.constraint(equalTo: logInButton.bottomAnchor, constant: 20),
            getPassButton.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            getPassButton.heightAnchor.constraint(equalToConstant: 50),
            getPassButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            getPassButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
        ])

        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        [logoImage, stackView, logInButton].forEach { contentView.addSubview($0) }
        [userLoginTextField, userPasswordTextField].forEach { stackView.addArrangedSubview($0) }

        NSLayoutConstraint.activate([
            
            logoImage.centerXAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerXAnchor),
            logoImage.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 120),
            logoImage.heightAnchor.constraint(equalToConstant: 100),
            logoImage.widthAnchor.constraint(equalToConstant: 100),
            
            stackView.topAnchor.constraint(equalTo: logoImage.bottomAnchor, constant: 120),
            stackView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            stackView.heightAnchor.constraint(equalToConstant: 100),
            
            userLoginTextField.heightAnchor.constraint(equalToConstant: 50),
            userPasswordTextField.heightAnchor.constraint(equalToConstant: 50),
                 
            logInButton.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            logInButton.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            logInButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 16),
            logInButton.heightAnchor.constraint(equalToConstant: 50),
            logInButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            
            activityIndicator.centerYAnchor.constraint(equalTo: userPasswordTextField.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: userPasswordTextField.centerXAnchor)
        ])
    }
}

extension LogInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}
