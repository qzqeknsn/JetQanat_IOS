import UIKit
import SnapKit

class RentalsViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Rentals"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private let placeholderContainer: UIView = {
        let view = UIView()
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "calendar.badge.clock")?.withRenderingMode(.alwaysTemplate)
        iv.tintColor = UIColor(hex: "F4B400") // Brand Yellow
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Coming Soon"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let subMessageLabel: UILabel = {
        let label = UILabel()
        label.text = "We are working hard to bring you the best bike rental experience. Stay tuned!"
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .gray
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - Setup UI

    private func setupUI() {
        view.backgroundColor = UIColor(hex: "0A0A0A")
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        view.addSubview(titleLabel)
        view.addSubview(placeholderContainer)
        
        placeholderContainer.addSubview(iconImageView)
        placeholderContainer.addSubview(messageLabel)
        placeholderContainer.addSubview(subMessageLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.equalToSuperview().offset(20)
        }
        
        placeholderContainer.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(40)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.height.equalTo(80)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview()
        }
        
        subMessageLabel.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}
