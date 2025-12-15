//
//  HeroBannerCell.swift
//  JetQanat
//
//  Created by Zhooldibay Abylay on 16.12.2025.
//

import UIKit
import SnapKit

class HeroBannerCell: UICollectionViewCell {
    
    static let reuseIdentifier = "HeroBannerCell"
    
    // MARK: - Components
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        return view
    }()
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    
    private let gradientView: UIView = {
       let view = UIView()
       return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .black)
        label.textColor = .white
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14) 
        label.textColor = UIColor.white.withAlphaComponent(0.9)
        return label
    }()
    
    private let badgeContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12 
        return view
    }()
    
    private let badgeLabel: UILabel = {
        let label = UILabel()
        label.text = "EXCLUSIVE"
        label.font = .systemFont(ofSize: 11, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private let badgeIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "bolt.fill")
        iv.tintColor = .black
        return iv
    }()
    
    // MARK: - Variables
    
    private var accentColor: UIColor = .white
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {

    }
    
    // MARK: - Setup
    
    private func setupUI() {

        contentView.backgroundColor = .clear
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 10)
        contentView.layer.shadowRadius = 20
        contentView.layer.shadowOpacity = 0.3
        
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        containerView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        containerView.addSubview(gradientView)
        gradientView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // Text Content
        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 8
        
        containerView.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.bottom.equalToSuperview().inset(24)
            make.trailing.lessThanOrEqualToSuperview().inset(24)
        }
        
        // Badge
        badgeContainer.addSubview(badgeIcon)
        badgeContainer.addSubview(badgeLabel)
        
        badgeIcon.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(12)
        }
        
        badgeLabel.snp.makeConstraints { make in
            make.leading.equalTo(badgeIcon.snp.trailing).offset(4)
            make.trailing.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(6)
        }
        
        stack.addArrangedSubview(badgeContainer)
        stack.setCustomSpacing(8, after: subtitleLabel) 
    }
    
    // MARK: - Configuration
    
    func configure(title: String, subtitle: String, imageName: String, accentColor: UIColor) {
        titleLabel.text = title
        titleLabel.textColor = .white
        subtitleLabel.text = subtitle
        imageView.image = UIImage(named: imageName)
        self.accentColor = accentColor
        
        badgeContainer.backgroundColor = accentColor
        
        
        if gradientView.layer.sublayers == nil {
            let gradient = CAGradientLayer()
            gradient.colors = [UIColor.black.withAlphaComponent(0.7).cgColor, UIColor.clear.cgColor]
            gradient.startPoint = CGPoint(x: 0, y: 1)
            gradient.endPoint = CGPoint(x: 1, y: 0)
            gradient.frame = contentView.bounds
            gradientView.layer.addSublayer(gradient)
        }
    }
}
