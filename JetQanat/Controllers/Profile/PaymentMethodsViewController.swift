//
//  PaymentMethodsViewController.swift
//  JetQanat
//
//  Created by Amangeldin Yersultan on 15.12.2025.
//

import UIKit
import SnapKit

class PaymentMethodsViewController: UIViewController {
    
    // MARK: - Properties
    
    // For now simple empty state or list
    
    // MARK: - UI Components
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Payment Methods"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No saved cards"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .gray
        label.textAlignment = .center
        return label
    }()
    
    private let addCardButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("+ Add New Card", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = UIColor(hex: "FFB800")
        btn.layer.cornerRadius = 12
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        return btn
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = UIColor(hex: "1C1C1E")
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.centerX.equalToSuperview()
        }
        
        view.addSubview(emptyStateLabel)
        emptyStateLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        view.addSubview(addCardButton)
        addCardButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-30)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(50)
        }
        
        addCardButton.addTarget(self, action: #selector(didTapAddCard), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc private func didTapAddCard() {
        let alert = UIAlertController(title: "Add Card", message: "Card entry implementation pending.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
