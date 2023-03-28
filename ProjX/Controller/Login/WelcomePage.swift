    //
    //  WelcomePage.swift
    //  ProjX
    //
    //  Created by Sathya on 17/03/23.
    //

import UIKit

class WelcomePage: PROJXViewController {

    lazy var logoImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "ProjX3D"))
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowRadius = 20
        imageView.layer.shadowOpacity = 0.7
        imageView.layer.shadowOffset = CGSize(width: 0, height: 70)
        imageView.clipsToBounds = false
        imageView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return imageView
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "ProjX"
        label.textColor = .label
        label.font = .systemFont(ofSize: 25, weight: .heavy)
        return label
    }()

    lazy var welcomeDescription: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.text = "Your one stop for all task management solutions"
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        return label
    }()

    lazy var ProjXStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [logoImage, titleLabel, welcomeDescription])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.alignment = .center
        return stackView
    }()

    lazy var loginButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.configuration = UIButton.Configuration.plain()
        button.tag = 0
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = UIColor(hex: 0x7289da, alpha: 0.3)
        button.layer.borderWidth = 2.5
        button.layer.borderColor = UIColor(hex: 0x7289da).cgColor
        button.tintColor = .label
        button.layer.cornerRadius = 7
        button.addTarget(self, action: #selector(buttonOnClick), for: .touchUpInside)
        return button
    }()


    var neededVariable = {
        let imageView = UIImageView()
        imageView.backgroundColor = .label
        return imageView
    }()

    @objc func buttonOnClick(_ sender: UIButton) {
        let signInVC = SigninVC()
        signInVC.signInDelegate = self
        let navController = UINavigationController(rootViewController: signInVC)
        navController.modalPresentationStyle = .formSheet
        present(navController, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        configureConstraints()
    }

    private func configureView() {
        view.addSubview(ProjXStackView)
        view.addSubview(loginButton)
        animateImageView()
    }

    private func animateImageView() {
        let startingPosition = logoImage.frame.origin.y
        let options: UIView.AnimationOptions = [.curveEaseInOut, .autoreverse, .repeat, .preferredFramesPerSecond60]
        let animationBlock = { [weak self] in
            self?.logoImage.frame.origin.y = startingPosition + 25
            self?.logoImage.layer.shadowOffset = CGSize(width: 0, height: 20)
            self?.logoImage.layer.shadowOpacity = 1
            self?.logoImage.layer.shadowRadius = 10
            return
        }
        UIView.animate(withDuration: 2, delay: 0, options: options, animations: animationBlock, completion: nil)
    }

    private func configureConstraints() {

        NSLayoutConstraint.activate([
            logoImage.widthAnchor.constraint(equalToConstant: 320),
            logoImage.heightAnchor.constraint(equalToConstant: 320),

            welcomeDescription.widthAnchor.constraint(equalToConstant: view.bounds.width - 30),

            ProjXStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ProjXStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
            ProjXStackView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),

            loginButton.widthAnchor.constraint(equalToConstant: 100),
            loginButton.heightAnchor.constraint(equalToConstant: 45),
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.topAnchor.constraint(equalTo: ProjXStackView.bottomAnchor, constant: 65)
        ])
    }
}

extension WelcomePage: SignUpDelegate, SignInDelegate {

    private func presentSignUp() {
        let signUpVC = SignupVC()
        signUpVC.signUpDelegate = self
        let navController = UINavigationController(rootViewController: signUpVC)
        navController.modalPresentationStyle = .formSheet
        self.present(navController, animated: true)
    }

    private func presentSignIn() {
        let signInVC = SigninVC()
        signInVC.signInDelegate = self
        let navController = UINavigationController(rootViewController: signInVC)
        navController.modalPresentationStyle = .formSheet
        self.present(navController, animated: true)
    }

    func signUpSwitchButtonPressed() {
        dismiss(animated: true) { [weak self] in
            self?.presentSignUp()
        }
    }

    private func showActivityIndicatorOnLoginButton() {
        loginButton.setTitle("", for: .normal)
        loginButton.backgroundColor = .systemGray2.withAlphaComponent(0.3)
        loginButton.layer.borderColor = UIColor.systemGray2.cgColor
        loginButton.configuration?.showsActivityIndicator = true
    }

    func successfulLogin() {
        showActivityIndicatorOnLoginButton()
        dismiss(animated: true) {
            SceneDelegate.shared?.switchToHomePageVC()
        }
    }

    func signInSwitchButtonPressed() {
        dismiss(animated: true) { [weak self] in
            self?.presentSignIn()
        }
    }

    func successfulRegister(user: User) {
        showActivityIndicatorOnLoginButton()
        dismiss(animated: true) { [weak self] in
            let authenticationStatus = SessionManager.shared.authenticate(username: user.username!, password: user.password!)
            switch authenticationStatus {
                case .failure:
                    let alert = UIAlertController(title: "Error", message: "An error occured while authenticating. Please Sign in using your new account to continue", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Sign In", style: .default, handler: { [weak self] _ in
                        self?.loginButton.setTitle("Login", for: .normal)
                        self?.loginButton.backgroundColor = UIColor(hex: 0x7289da, alpha: 0.3)
                        self?.loginButton.layer.borderColor = UIColor(hex: 0x7289da).cgColor
                        self?.loginButton.configuration?.showsActivityIndicator = false
                        self?.presentSignIn()
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                    self?.present(alert, animated: true)
                case .success:
                    SceneDelegate.shared?.switchToHomePageVC()
            }
        }
    }
}
