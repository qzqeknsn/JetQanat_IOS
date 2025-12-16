//
//  CartItemCell.swift
//  JetQanat
//
//  Created by Amangeldin Yersultan on 16.12.2025.
//

import UIKit
import SnapKit

class CartItemCell: UITableViewCell {
    
    var onToggleSelection: (() -> Void)?
    var onQuantityChange: ((Int) -> Void)?
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "1C1C1E")
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let checkButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.tintColor = .accentGold
        return btn
    }()
    
    private let productImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .darkGray
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 8
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14, weight: .bold)
        l.textColor = .white
        l.numberOfLines = 2
        return l
    }()
    
    private let detailLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .regular)
        l.textColor = .gray
        return l
    }()
    
    private let priceLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16, weight: .bold)
        l.textColor = .white
        return l
    }()
    
   
    private let stepperContainer = UIView()
    private let minusButton = UIButton(type: .system)
    private let plusButton = UIButton(type: .system)
    private let countLabel = UILabel()
    
    private var currentQty: Int = 1
    
    static let reuseIdentifier = "CartItemCell"
    
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
        
        containerView.addSubview(checkButton)
        checkButton.snp.makeConstraints { make in
            make.top.leading.equalTo(12)
            make.width.height.equalTo(24)
        }
        
        containerView.addSubview(productImageView)
        productImageView.snp.makeConstraints { make in
            make.leading.equalTo(checkButton.snp.trailing).offset(12)
            make.top.equalTo(12)
            make.width.height.equalTo(80)
        }
        
        containerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(productImageView.snp.trailing).offset(12)
            make.top.equalTo(12)
            make.trailing.equalTo(-12)
        }
        
        containerView.addSubview(detailLabel)
        detailLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
        }
        
        containerView.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.bottom.equalTo(productImageView)
        }
        
        
        setupStepper()
        containerView.addSubview(stepperContainer)
        stepperContainer.snp.makeConstraints { make in
            make.trailing.equalTo(-12)
            make.bottom.equalTo(-12)
            make.width.equalTo(90)
            make.height.equalTo(32)
        }
        
        checkButton.addTarget(self, action: #selector(didTapCheck), for: .touchUpInside)
    }
    
    private func setupStepper() {
        stepperContainer.backgroundColor = UIColor(white: 1, alpha: 0.1)
        stepperContainer.layer.cornerRadius = 16
        
        minusButton.setTitle("-", for: .normal)
        minusButton.setTitleColor(.white, for: .normal)
        minusButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        minusButton.addTarget(self, action: #selector(didTapMinus), for: .touchUpInside)
        
        plusButton.setTitle("+", for: .normal)
        plusButton.setTitleColor(.white, for: .normal)
        plusButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        plusButton.addTarget(self, action: #selector(didTapPlus), for: .touchUpInside)
        
        countLabel.textColor = .white
        countLabel.font = .systemFont(ofSize: 14, weight: .bold)
        countLabel.textAlignment = .center
        
        stepperContainer.addSubview(minusButton)
        stepperContainer.addSubview(plusButton)
        stepperContainer.addSubview(countLabel)
        
        minusButton.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(30)
        }
        
        plusButton.snp.makeConstraints { make in
            make.trailing.top.bottom.equalToSuperview()
            make.width.equalTo(30)
        }
        
        countLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    func configure(with item: CartItem) {
        titleLabel.text = item.product.title
        priceLabel.text = item.product.price
        productImageView.image = UIImage(named: item.product.imageName)
        currentQty = item.quantity
        countLabel.text = "\(currentQty)"
        
        
        if item.product.category == "Motorcycles" {
            detailLabel.text = "Model: 2024"
        } else {
            detailLabel.text = "Color: Standard"
        }
        
        let icon = item.isSelected ? "checkmark.square.fill" : "square"
        checkButton.setImage(UIImage(systemName: icon), for: .normal)
        checkButton.tintColor = item.isSelected ? .accentGold : .gray
    }
    
    @objc private func didTapCheck() { onToggleSelection?() }
    
    @objc private func didTapMinus() {
        if currentQty > 1 {
            currentQty -= 1
            onQuantityChange?(currentQty)
        } else {
            
            onQuantityChange?(0)
        }
    }
    
    @objc private func didTapPlus() {
        currentQty += 1
        onQuantityChange?(currentQty)
    }
}
