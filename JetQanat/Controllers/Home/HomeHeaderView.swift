//
//  HomeHeaderView.swift
//  JetQanat
//
//  Created by Zholdibay Abylay on 16.12.2025.
//

import UIKit
import SnapKit

class HomeHeaderView: UIView {
    
    // MARK: - Tap Handlers
    
    var onAvatarTap: (() -> Void)?
    var onNotificationTap: (() -> Void)?
    var onCartTap: (() -> Void)?
    
    // MARK: - UI Components
    
    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = UIColor(hex: "1E2836")
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 24
        iv.image = UIImage(systemName: "person.circle.fill")
        iv.tintColor = .gray
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    private let greetingLabel: UILabel = {
        let label = UILabel()
        label.text = "Good Morning 👋"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Motor Hub User"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private let notificationButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "bell"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private let cartButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "cart"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = UIColor(hex: "0A0A0A")
        
        
        addSubview(avatarImageView)
        avatarImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(48)
        }
        
        
        let textStack = UIStackView(arrangedSubviews: [greetingLabel, nameLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.alignment = .leading
        
        addSubview(textStack)
        textStack.snp.makeConstraints { make in
            make.leading.equalTo(avatarImageView.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
        }
        
        // Buttons
        let buttonsStack = UIStackView(arrangedSubviews: [notificationButton, cartButton])
        buttonsStack.axis = .horizontal
        buttonsStack.spacing = 20
        
        addSubview(buttonsStack)
        buttonsStack.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
        
        notificationButton.snp.makeConstraints { make in
            make.width.height.equalTo(24)
        }
        
        cartButton.snp.makeConstraints { make in
            make.width.height.equalTo(24)
        }
    }
    
    private func setupActions() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapAvatar))
        avatarImageView.addGestureRecognizer(tap)
        
        notificationButton.addTarget(self, action: #selector(didTapNotification), for: .touchUpInside)
        cartButton.addTarget(self, action: #selector(didTapCart), for: .touchUpInside)
    }
    
    // MARK: - Configuration
    
    func configure(user: User?) {
        if let user = user {
            nameLabel.text = user.fullName
            
        } else {
            nameLabel.text = "Guest"
        }
    }
    
    // MARK: - Actions
    
    @objc private func didTapAvatar() {
        onAvatarTap?()
    }
    
    @objc private func didTapNotification() {
        onNotificationTap?()
    }
    
    @objc private func didTapCart() {
        onCartTap?()
    }
}
