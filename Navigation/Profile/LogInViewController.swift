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
        self.userPasswordTextField.isSecureTextEntry = true
        self.userPasswordTextField.text = "qaz"
        let queue = DispatchQueue(label: "ru.IOSInt-homeworks.9", attributes: .concurrent)
        let workItem = DispatchWorkItem {
            self.brutForceService.bruteForce(passwordToUnlock: "qaz")
        }
        self.activityIndicator.startAnimating()
        queue.async(execute: workItem)
        workItem.notify(queue: .main) {
            self.userPasswordTextField.isSecureTextEntry = false
            self.activityIndicator.stopAnimating()
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
        scrollView.addSubview(logoImage)
        stackView.addArrangedSubview(userLoginTextField)
        stackView.addArrangedSubview(userLoginTextField)
        scrollView.addSubview(stackView)
        scrollView.addSubview(logInButton)
        scrollView.addSubview(getPassButton)
        userLoginTextField.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            logoImage.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 120),
            logoImage.heightAnchor.constraint(equalToConstant: 120),
            logoImage.widthAnchor.constraint(equalToConstant: 120),
            logoImage.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: logoImage.bottomAnchor, constant: 120),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -16),
            stackView.heightAnchor.constraint(equalToConstant: 100),
            logInButton.topAnchor.constraint(equalTo: stackView.bottomAnchor,constant: 16),
            logInButton.heightAnchor.constraint(equalToConstant: 50),
            logInButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            logInButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            getPassButton.topAnchor.constraint(equalTo: logInButton.bottomAnchor, constant: 20),
            getPassButton.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            getPassButton.heightAnchor.constraint(equalToConstant: 50),
            getPassButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            getPassButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            activityIndicator.centerYAnchor.constraint(equalTo: userLoginTextField.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: userLoginTextField.centerXAnchor)
            
        ])
    }
    
    @objc func dissmiskeyboard() {
        view.endEditing(true)
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        
    }
    
    @objc private func didShowKeyboard(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            let myButtonPointY =  logInButton.frame.origin.y + logInButton.frame.height
            let keyboardOriginY = scrollView.frame.height - keyboardHeight
            let yOffset = keyboardOriginY < myButtonPointY ? myButtonPointY - keyboardOriginY + 16 : 0
            
            scrollView.contentOffset = CGPoint(x: 0, y: yOffset)
        }
    }
    @objc private func didHideKeyboard(_ notification: Notification) {
        self.dissmiskeyboard()
    }
    
    private func setupGestures() {
        let tapDissmis = UITapGestureRecognizer(target: self, action: #selector(dissmiskeyboard))
        view.addGestureRecognizer(tapDissmis)
    }
    func stateMyButton(sender: UIButton) {
        switch sender.state {
        case .normal:
            sender.alpha = 1.0
        case .selected:
            sender.alpha = 0.8
        case .highlighted:
            sender.alpha = 0.8
        default:
            sender.alpha = 1.0
        }
    }
}

extension LogInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}
