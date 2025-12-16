//
//  OrderCell.swift
//  JetQanat
//
//  Created by Amangeldin Yersultan on 16.12.2025.
//

import UIKit
import SnapKit

class OrderCell: UITableViewCell {
    
    static let reuseIdentifier = "OrderCell"
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "1C1C1E")
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let statusBadge: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hex: "34C759").withAlphaComponent(0.2)
        v.layer.cornerRadius = 10
        return v
    }()
    
    private let statusLabel: UILabel = {
        let l = UILabel()
        l.textColor = UIColor(hex: "34C759")
        l.font = .systemFont(ofSize: 11, weight: .bold)
        return l
    }()
    
    private let codeLabel: UILabel = {
        let l = UILabel()
        l.textColor = .gray
        l.font = .systemFont(ofSize: 12, weight: .medium)
        return l
    }()
    
    private let titlesLabel: UILabel = {
        let l = UILabel()
        l.textColor = .white
        l.font = .systemFont(ofSize: 15, weight: .bold)
        l.numberOfLines = 2
        return l
    }()
    
    private let priceLabel: UILabel = {
        let l = UILabel()
        l.textColor = .white
        l.font = .systemFont(ofSize: 16, weight: .bold)
        l.textAlignment = .right
        return l
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 20))
        }
        
        containerView.addSubview(statusBadge)
        statusBadge.addSubview(statusLabel)
        
        statusBadge.snp.makeConstraints { make in
            make.top.leading.equalTo(16)
            make.height.equalTo(20)
        }
        
        statusLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(8)
        }
        
        containerView.addSubview(codeLabel)
        codeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(statusBadge)
            make.trailing.equalTo(-16)
        }
        
        containerView.addSubview(titlesLabel)
        titlesLabel.snp.makeConstraints { make in
            make.top.equalTo(statusBadge.snp.bottom).offset(12)
            make.leading.equalTo(16)
            make.trailing.equalTo(-100) // Space for price
        }
        
        containerView.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { make in
            make.centerY.equalTo(titlesLabel)
            make.trailing.equalTo(-16)
        }
    }
    
    func configure(with order: Order) {
        let color = UIColor(hex: order.status.color)
        statusBadge.backgroundColor = color.withAlphaComponent(0.2)
        statusLabel.textColor = color
        statusLabel.text = order.status.rawValue.uppercased()
        
        codeLabel.text = order.orderCode
        titlesLabel.text = order.productTitles.joined(separator: ", ")
        priceLabel.text = order.formattedTotal
    }
}
