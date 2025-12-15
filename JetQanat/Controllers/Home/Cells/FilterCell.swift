//
//  FilterCell.swift
//  JetQanat
//
//  Created by Zholdibay Abylay on 16.12.2025.
//

import UIKit
import SnapKit

class FilterCell: UICollectionViewCell {
    static let reuseIdentifier = "FilterCell"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.layer.cornerRadius = 20
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(title: String, isSelected: Bool) {
        titleLabel.text = title
        if isSelected {
            contentView.backgroundColor = UIColor(hex: "FFB800")
            titleLabel.textColor = .black
        } else {
            contentView.backgroundColor = UIColor(hex: "2A2A2A")
            titleLabel.textColor = .white
        }
    }
}
