//
//  BrandCell.swift
//  JetQanat
//
//  Created by Zholdibay Abylay on 16.12.2025.
//

import UIKit
import SnapKit

class BrandCell: UICollectionViewCell {
    
    static let reuseIdentifier = "BrandCell"
    
    private let circleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "2A2A2A") 
        view.layer.cornerRadius = 30
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = UIColor(hex: "FFB800")
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(circleView)
        circleView.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(60)
        }
        
        circleView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(28)
        }
        
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(circleView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }
    }
    
    func configure(name: String, iconName: String) {
        nameLabel.text = name
        
        if let customImage = UIImage(named: iconName) {
            iconImageView.image = customImage
        } else {
            iconImageView.image = UIImage(systemName: iconName)
        }
    }
}
