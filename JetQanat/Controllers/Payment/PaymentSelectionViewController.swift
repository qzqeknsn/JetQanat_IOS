//
//  PaymentSelectionViewController.swift
//  JetQanat
//
//  Created by Amangeldin Yersultan on 15.12.2025.
//

import UIKit
import SnapKit

class PaymentSelectionViewController: UIViewController {
    
    // MARK: - Properties
    
    var onMethodSelected: ((String) -> Void)?
    
    // MARK: - UI Components
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "1C1C1E")
        view.layer.cornerRadius = 24
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Choose Payment Method"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private lazy var applePayButton: UIButton = {
        let btn = createPaymentButton(title: "Apple Pay", icon: "applelogo", bgColor: .white, textColor: .black)
        btn.addTarget(self, action: #selector(didTapApplePay), for: .touchUpInside)
        return btn
    }()
    
    private lazy var googlePayButton: UIButton = {
        let btn = createPaymentButton(title: "Google Pay", icon: "g.circle.fill", bgColor: UIColor(hex: "4285F4"), textColor: .white)
        btn.addTarget(self, action: #selector(didTapGooglePay), for: .touchUpInside)
        return btn
    }()
    
    private lazy var cardButton: UIButton = {
        let btn = createPaymentButton(title: "Pay with Card", icon: "creditcard.fill", bgColor: UIColor(hex: "FFB800"), textColor: .black)
        btn.addTarget(self, action: #selector(didTapCard), for: .touchUpInside)
        return btn
    }()
    
    private let closeButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
        btn.setImage(UIImage(systemName: "xmark", withConfiguration: config), for: .normal)
        btn.tintColor = .gray
        btn.backgroundColor = UIColor(white: 1, alpha: 0.1)
        btn.layer.cornerRadius = 15
        return btn
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        // Tap to dismiss on background
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapClose))
        view.addGestureRecognizer(tap)
        
        view.addSubview(containerView)
        containerView.addGestureRecognizer(UITapGestureRecognizer()) 
        
        containerView.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(350)
        }
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(closeButton)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(24)
            make.centerX.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalTo(-20)
            make.width.height.equalTo(30)
        }
        
        let stack = UIStackView(arrangedSubviews: [applePayButton, googlePayButton, cardButton])
        stack.axis = .vertical
        stack.spacing = 16
        stack.distribution = .fillEqually
        
        containerView.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(182) 
        }
    }
    
    private func createPaymentButton(title: String, icon: String, bgColor: UIColor, textColor: UIColor) -> UIButton {
        let btn = UIButton(type: .system)
        btn.backgroundColor = bgColor
        btn.layer.cornerRadius = 12
        
        // Image logic
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        let image = UIImage(systemName: icon, withConfiguration: config)
        btn.setImage(image, for: .normal)
        btn.tintColor = textColor
        
        btn.setTitle("   \(title)", for: .normal)
        btn.setTitleColor(textColor, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        
        return btn
    }
    
    // MARK: - Actions
    
    @objc private func didTapClose() {
        dismiss(animated: true)
    }
    
    @objc private func didTapApplePay() {
        simulateProcessing {
            self.onMethodSelected?("Apple Pay")
            self.dismiss(animated: true)
        }
    }
    
    @objc private func didTapGooglePay() {
        simulateProcessing {
            self.onMethodSelected?("Google Pay")
            self.dismiss(animated: true)
        }
    }
    
    @objc private func didTapCard() {
        // Here we'd typically navigate to card list.
        // For now, we'll just return "Card" method, and let parent handle navigation or logic.
        // Or we could push the PaymentMethodsViewController here.
        
        dismiss(animated: true) {
            self.onMethodSelected?("Card")
        }
    }
    
    private func simulateProcessing(completion: @escaping () -> Void) {
        let alert = UIAlertController(title: "Processing", message: "Contacting payment provider...", preferredStyle: .alert)
        present(alert, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            alert.dismiss(animated: true, completion: completion)
        }
    }
}
