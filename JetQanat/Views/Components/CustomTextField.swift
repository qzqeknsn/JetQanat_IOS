import UIKit
import SnapKit

class CustomTextField: UIView {
    
    // MARK: - Components
    
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = .gray
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    let textField: UITextField = {
        let tf = UITextField()
        tf.textColor = .white
        tf.font = .systemFont(ofSize: 16)
        tf.backgroundColor = .clear
        return tf
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "1E2836")
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        return view
    }()
    
    // MARK: - Init
    
    init(icon: String, placeholder: String, isSecure: Bool = false) {
        super.init(frame: .zero)
        setupUI(icon: icon, placeholder: placeholder, isSecure: isSecure)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI(icon: String, placeholder: String, isSecure: Bool) {
        addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(56) 
        }
        
        containerView.addSubview(iconImageView)
        iconImageView.image = UIImage(systemName: icon)
        iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        containerView.addSubview(textField)
        textField.placeholder = placeholder
        textField.isSecureTextEntry = isSecure
        
        
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
        )
        
        textField.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.height.equalToSuperview()
        }
    }
    
    // MARK: - Accessors
    
    var text: String? {
        get { return textField.text }
        set { textField.text = newValue }
    }
}
