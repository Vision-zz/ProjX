//
//  WelcomePage.swift
//  Enceladus
//
//  Created by Sathya on 17/03/23.
//

import UIKit

class WelcomePage: ELDSViewController {

    lazy var logoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.shadowColor = UIColor(hex: 0x020202).cgColor
        imageView.layer.shadowRadius = 12
        imageView.layer.shadowOpacity = 1
        imageView.layer.shadowOffset = CGSize(width: 0, height: 0)
        imageView.clipsToBounds = false
        imageView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return imageView
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 22, weight: .heavy)
        return label
    }()

    lazy var welcomeDescription: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        return label
    }()

    lazy var enceladusStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [logoImage, titleLabel, welcomeDescription])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.setCustomSpacing(40, after: logoImage)
        stackView.alignment = .center
        return stackView
    }()

    lazy var loginButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.tag = 0
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = UIColor(hex: 0x7289da, alpha: 0.3)
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor(hex: 0x7289da, alpha: 1).cgColor
        button.tintColor = .label
        button.layer.cornerRadius = 7
        button.addTarget(self, action: #selector(buttonOnClick), for: .touchDown)
        return button
    }()

    lazy var signUpVC: UIViewController = {
        let signUpVC = SignupVC()
        signUpVC.signUpDelegate = self
        let navController = UINavigationController(rootViewController: signUpVC)
        navController.modalPresentationStyle = .formSheet
        return navController
    }()

    lazy var signInVC: UIViewController = {
        let signInVC = SigninVC()
        signInVC.signInDelegate = self
        let navController = UINavigationController(rootViewController: signInVC)
        navController.modalPresentationStyle = .formSheet
        return navController
    }()

    @objc func buttonOnClick(_ sender: UIButton) {
        present(signInVC, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        configureConstraints()
    }

    private func configureUI() {

        logoImage.image = UIImage(named: "EnceladusLogo")
        titleLabel.text = "Enceladus"
        welcomeDescription.text = "Your one stop for all task management solutions"

        view.addSubview(enceladusStackView)
        view.addSubview(loginButton)

    }

    private func configureConstraints() {

        NSLayoutConstraint.activate([
            logoImage.widthAnchor.constraint(equalToConstant: 250),
            logoImage.heightAnchor.constraint(equalToConstant: 250),

            welcomeDescription.widthAnchor.constraint(equalToConstant: view.bounds.width - 30),

            enceladusStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            enceladusStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
            enceladusStackView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),

            loginButton.widthAnchor.constraint(equalToConstant: 100),
            loginButton.heightAnchor.constraint(equalToConstant: 45),
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.topAnchor.constraint(equalTo: enceladusStackView.bottomAnchor, constant: 75)
        ])

    }

}

extension WelcomePage: SignUpDelegate, SignInDelegate {
    func signUpButtonPressed() {
        signInVC.dismiss(animated: true) { [weak self] in
            self?.present(self!.signUpVC, animated: true)
        }
    }

    func signInButtonPressed() {
        signUpVC.dismiss(animated: true) { [weak self] in
            self?.present(self!.signInVC, animated: true)
        }
    }
}
