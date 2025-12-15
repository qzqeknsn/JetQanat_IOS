//
//  BikeCardCell.swift
//  JetQanat
//
//  Created by Amangeldin Yersultan on 16.12.2025.
//

import UIKit
import SnapKit

class BikeCardCell: UICollectionViewCell {
    
    static let reuseIdentifier = "BikeCardCell"
    
    // MARK: - Components
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#1E1E1E")
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        return view
    }()
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        iv.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        iv.backgroundColor = .darkGray
        return iv
    }()
    
    
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Product Name"
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private let ratingContainer: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        return stack
    }()
    
    private let ratingIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "star.fill"))
        iv.tintColor = UIColor(red: 244/255, green: 180/255, blue: 0/255, alpha: 1)
        iv.setContentHuggingPriority(.required, for: .horizontal)
        return iv
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.text = "4.8 (12)"
        label.font = .systemFont(ofSize: 11)
        label.textColor = .lightGray
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.text = "$0"
        label.font = .systemFont(ofSize: 16, weight: .heavy)
        label.textColor = UIColor(red: 244/255, green: 180/255, blue: 0/255, alpha: 1)
        return label
    }()
    
    
    private let buyButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Buy", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = UIColor(red: 244/255, green: 180/255, blue: 0/255, alpha: 1)
        btn.titleLabel?.font = .systemFont(ofSize: 12, weight: .bold)
        btn.layer.cornerRadius = 6
        return btn
    }()
    
    private let cartButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
        btn.setImage(UIImage(systemName: "cart.fill.badge.plus", withConfiguration: config), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        btn.layer.cornerRadius = 6
        return btn
    }()
    
    private let bookButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Book Now", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = UIColor(hex: "FFB800") 
        btn.titleLabel?.font = .systemFont(ofSize: 12, weight: .bold)
        btn.layer.cornerRadius = 6
        btn.isHidden = true 
        return btn
    }()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Setup
    
    private func setupUI() {
        contentView.backgroundColor = .clear
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // Image
        containerView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(110)
        }
        
        // Title
        containerView.addSubview(titleLabel)
        titleLabel.numberOfLines = 1
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(10)
        }
        
        // Rating
        containerView.addSubview(ratingContainer)
        ratingContainer.addArrangedSubview(ratingIcon)
        ratingContainer.addArrangedSubview(ratingLabel)
        
        ratingIcon.snp.makeConstraints { make in make.width.height.equalTo(10) }
        
        ratingContainer.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalToSuperview().inset(10)
        }
        
        // Price
        containerView.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(ratingContainer.snp.bottom).offset(6)
            make.leading.equalToSuperview().inset(10)
        }
        
        // Buttons Stack
        let buttonStack = UIStackView(arrangedSubviews: [buyButton, cartButton, bookButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 8
        buttonStack.distribution = .fillProportionally
        
        containerView.addSubview(buttonStack)
        
        buttonStack.snp.makeConstraints { make in
            make.top.equalTo(priceLabel.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalToSuperview().inset(10)
            make.height.equalTo(25)
        }
        
        cartButton.snp.makeConstraints { make in
            make.width.equalTo(29)
        }
        
        // Actions
        buyButton.addTarget(self, action: #selector(didTapBuy), for: .touchUpInside)
        cartButton.addTarget(self, action: #selector(didTapCart), for: .touchUpInside)
        bookButton.addTarget(self, action: #selector(didTapBook), for: .touchUpInside)
    }
    
    // MARK: - Configuration
    
    var onBuyTap: (() -> Void)?
    var onCartTap: (() -> Void)?
    var onBookTap: (() -> Void)?
    
    func configure(with bike: Bike) {
        // Mode: Sales
        buyButton.isHidden = false
        cartButton.isHidden = false
        bookButton.isHidden = true
        
        titleLabel.text = bike.name
        priceLabel.text = bike.formattedPrice
        ratingLabel.text = "4.8 (12)"
        
        if let image = UIImage(named: bike.image_url) {
            imageView.image = image
        } else {
            imageView.backgroundColor = .darkGray
        }
    }
    
    // Support for RentalBike
    func configure(with rental: RentalBike) {
        // Mode: Rental
        buyButton.isHidden = true
        cartButton.isHidden = true
        bookButton.isHidden = false
        
        titleLabel.text = rental.model
        priceLabel.text = "$\(Int(rental.pricePerPeriod))"
        ratingLabel.text = String(format: "%.1f (20)", rental.rating)
        
        if let image = UIImage(named: rental.imageName) {
            imageView.image = image
        } else {
            imageView.backgroundColor = .darkGray
        }
    }
    
    // MARK: - Actions
    @objc private func didTapBuy() { onBuyTap?() }
    @objc private func didTapCart() { onCartTap?() }
    @objc private func didTapBook() { onBookTap?() }
}
