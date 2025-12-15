
import UIKit
import SnapKit

class ProfileMenuItem: UIButton {
    
    private let iconContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "2A3544")
        view.layer.cornerRadius = 22 // 44/2
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let menuTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16) 
        label.textColor = .white
        return label
    }()
    
    private let badgeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .white
        label.numberOfLines = 1
        label.textAlignment = .center
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.backgroundColor = UIColor(hex: "FFB800")
        label.isHidden = true
        return label
    }()
    
    private let chevronImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "chevron.right")
        iv.tintColor = .gray
        return iv
    }()
    
    init(icon: String, title: String, badge: String? = nil) {
        super.init(frame: .zero)
        setupUI()
        configure(icon: icon, title: title, badge: badge)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor(hex: "1E2836")
        layer.cornerRadius = 16
        
        addSubview(iconContainer)
        iconContainer.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44)
            make.top.bottom.equalToSuperview().inset(12) 
        }
        
        iconContainer.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(24) 
        }
        
        addSubview(chevronImageView)
        chevronImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(12)
        }
        
        addSubview(badgeLabel)
        badgeLabel.snp.makeConstraints { make in
            make.trailing.equalTo(chevronImageView.snp.leading).offset(-12)
            make.centerY.equalToSuperview()
            make.height.equalTo(20)
            make.width.greaterThanOrEqualTo(20)
        }
        
        addSubview(menuTitleLabel)
        menuTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconContainer.snp.trailing).offset(16)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualTo(badgeLabel.isHidden ? chevronImageView.snp.leading : badgeLabel.snp.leading).offset(-8)
        }
    }
    
    func configure(icon: String, title: String, badge: String?) {
        iconImageView.image = UIImage(systemName: icon)
        menuTitleLabel.text = title
        if let badge = badge {
            badgeLabel.text = " \(badge) " 
            badgeLabel.isHidden = false
        } else {
            badgeLabel.isHidden = true
        }
    }
}
