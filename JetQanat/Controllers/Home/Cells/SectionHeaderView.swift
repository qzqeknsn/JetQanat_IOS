//
//  SectionHeaderView.swift
//  JetQanat
//
//  Created by Zholdibay Abylay on 16.12.2025.
//

import UIKit
import SnapKit

class SectionHeaderView: UICollectionReusableView {
    static let reuseIdentifier = "SectionHeaderView"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold) 
        label.textColor = .white
        return label
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("See All", for: .normal)
        button.setTitleColor(UIColor(hex: "FFB800"), for: .normal) 
        button.titleLabel?.font = .systemFont(ofSize: 14)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(titleLabel)
        addSubview(actionButton)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        actionButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
    }
    
    func configure(title: String, actionTitle: String? = "See All") {
        titleLabel.text = title
        actionButton.isHidden = (actionTitle == nil)
        if let actionTitle = actionTitle {
            actionButton.setTitle(actionTitle, for: .normal)
        }
    }
}
