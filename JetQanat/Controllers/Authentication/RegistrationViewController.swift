//
//  LoginViewController.swift
//  JetQanat
//
//  Created by Zholdybay Abylay on 16.12.2025.
//

import UIKit
import SnapKit

class RegistrationViewController: UIViewController {

    // MARK: - UI Components
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Create Your Trust Profile"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private let stepLabel: UILabel = {
        let label = UILabel()
        label.text = "Step 1 of 3"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()
    
    private let progressStack: UIStackView = {
        let stack = UIStackView()
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }()
    
    private func createProgressView(isActive: Bool) -> UIView {
        let view = UIView()
        view.backgroundColor = isActive ? UIColor(hex: "FFB800") : UIColor.gray.withAlphaComponent(0.3)
        view.layer.cornerRadius = 2
        view.snp.makeConstraints { make in
            make.height.equalTo(4)
        }
        return view
    }
    
    private let formStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        return stack
    }()
    
    private let nameField = CustomTextField(icon: "person.fill", placeholder: "Full Name")
    private let emailField = CustomTextField(icon: "envelope.fill", placeholder: "Email")
    private let phoneField = CustomTextField(icon: "phone.fill", placeholder: "Phone Number")
    private let passwordField = CustomTextField(icon: "lock.fill", placeholder: "Password", isSecure: true)
    
    private let trustBadgeContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "1E2836")
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let continueButton: UIButton = {
        let button = UIButton(type: .system)
        
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = UIColor(hex: "FFB800")
        config.baseForegroundColor = .black
        config.cornerStyle = .medium
        config.contentInsets = NSDirectionalEdgeInsets(top: 18, leading: 0, bottom: 18, trailing: 0)
        
        var titleContainer = AttributeContainer()
        titleContainer.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        config.attributedTitle = AttributedString("Continue", attributes: titleContainer)
        
        button.configuration = config
        button.layer.cornerRadius = 16
        
        return button
    }()

    private let viewModel: AuthenticationViewModel
    
    // MARK: - Lifecycle
    
    init(viewModel: AuthenticationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        configureBindings()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = UIColor(hex: "0F1419")
        
        // Header Stack
        let headerStack = UIStackView(arrangedSubviews: [headerLabel, stepLabel])
        headerStack.axis = .vertical
        headerStack.spacing = 8
        
        view.addSubview(headerStack)
        headerStack.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        // Progress Bars
        view.addSubview(progressStack)
        progressStack.addArrangedSubview(createProgressView(isActive: true))
        progressStack.addArrangedSubview(createProgressView(isActive: false))
        progressStack.addArrangedSubview(createProgressView(isActive: false))
        
        progressStack.snp.makeConstraints { make in
            make.top.equalTo(headerStack.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        // Form
        view.addSubview(formStack)
        formStack.addArrangedSubview(nameField)
        formStack.addArrangedSubview(emailField)
        formStack.addArrangedSubview(phoneField)
        formStack.addArrangedSubview(passwordField)
        
        formStack.snp.makeConstraints { make in
            make.top.equalTo(progressStack.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        // Trust Badge
        view.addSubview(trustBadgeContainer)
        let lockIcon = UIImageView(image: UIImage(systemName: "lock.shield.fill"))
        lockIcon.tintColor = UIColor(hex: "FFB800")
        lockIcon.contentMode = .scaleAspectFit
        
        let trustLabel = UILabel()
        trustLabel.text = "Your data is encrypted and secure"
        trustLabel.font = .systemFont(ofSize: 12)
        trustLabel.textColor = .gray
        
        trustBadgeContainer.addSubview(lockIcon)
        trustBadgeContainer.addSubview(trustLabel)
        
        trustBadgeContainer.snp.makeConstraints { make in
            make.top.equalTo(formStack.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(50)
        }
        
        lockIcon.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        trustLabel.snp.makeConstraints { make in
            make.leading.equalTo(lockIcon.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
        }
        
        // Button
        view.addSubview(continueButton)
        continueButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        // Navigation Bar styling
        navigationController?.navigationBar.tintColor = .white
    }
    
    private func setupActions() {
        continueButton.addTarget(self, action: #selector(didTapContinue), for: .touchUpInside)
    }
    
    private func configureBindings() {
        nameField.textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        emailField.textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        phoneField.textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordField.textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    @objc private func textDidChange(_ textField: UITextField) {
        if textField == nameField.textField { viewModel.fullName = textField.text ?? "" }
        if textField == emailField.textField { viewModel.email = textField.text ?? "" }
        if textField == phoneField.textField { viewModel.phone = textField.text ?? "" }
        if textField == passwordField.textField { viewModel.password = textField.text ?? "" }
    }
    
    // MARK: - Actions
    
    @objc private func didTapContinue() {
        // Validation logic could go here
        viewModel.submitRegistration()
        
        let verificationVC = VerificationViewController(viewModel: viewModel)
        navigationController?.pushViewController(verificationVC, animated: true)
    }
}
