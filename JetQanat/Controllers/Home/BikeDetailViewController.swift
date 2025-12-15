import UIKit
import SnapKit

class BikeDetailViewController: UIViewController {

    // MARK: - Properties
    private let bike: Bike

    // MARK: - UI Components
    

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.contentInsetAdjustmentBehavior = .never 
        return sv
    }()
    
    private let contentView = UIView()

    
    private let heroImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = UIColor(hex: "1C1C23")
        return iv
    }()
    
    
    private let imageGradient: UIView = {
        let view = UIView()
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.clear.cgColor, UIColor(hex: "0A0A0A").cgColor]
        gradient.locations = [0.0, 1.0]
        view.layer.addSublayer(gradient)
        return view
    }()

    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 26, weight: .bold)
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()

    private let ratingStack: UIStackView = {
        let icon = UIImageView(image: UIImage(systemName: "star.fill"))
        icon.tintColor = UIColor(hex: "F4B400")
        icon.contentMode = .scaleAspectFit
        icon.snp.makeConstraints { make in make.width.height.equalTo(16) }
        
        let label = UILabel()
        label.text = "4.8 (120 reviews)"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .lightGray
        
        let stack = UIStackView(arrangedSubviews: [icon, label])
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .center
        return stack
    }()
    
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .heavy)
        label.textColor = UIColor(hex: "F4B400") 
        return label
    }()
    
    private let specsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 12
        return stack
    }()

    
    private let descriptionTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Description"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = UIColor(white: 0.8, alpha: 1)
        label.numberOfLines = 0
        label.setLineHeight(lineHeight: 1.4)
        return label
    }()

    
    private let bottomBarView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "121212")
        let line = UIView()
        line.backgroundColor = UIColor(white: 1, alpha: 0.1)
        view.addSubview(line)
        line.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
        return view
    }()
    
    private let cartButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        btn.setImage(UIImage(systemName: "cart.badge.plus", withConfiguration: config), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor(white: 0.2, alpha: 1)
        btn.layer.cornerRadius = 12
        return btn
    }()
    
    private let buyButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Buy Now", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        btn.backgroundColor = UIColor(hex: "F4B400") // Желтый
        btn.layer.cornerRadius = 12

        
        btn.layer.shadowColor = UIColor(hex: "F4B400").cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 4)
        btn.layer.shadowRadius = 8
        btn.layer.shadowOpacity = 0.3
        return btn
    }()

    // MARK: - Lifecycle

    init(bike: Bike) {
        self.bike = bike
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureData()
        
       
        setupCustomBackButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let gradientLayer = imageGradient.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = imageGradient.bounds
        }
    }

    // MARK: - Setup UI

    private func setupUI() {
        view.backgroundColor = UIColor(hex: "0A0A0A")
        
        // 1. Добавляем ScrollView и ContentView
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // 2. Добавляем Bottom Bar (фиксированный)
        view.addSubview(bottomBarView)
        bottomBarView.addSubview(cartButton)
        bottomBarView.addSubview(buyButton)
        
        // Констрейнты основных блоков
        bottomBarView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(100) // Высота панели (включая Safe Area)
        }
        
        scrollView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(bottomBarView.snp.top) // Скролл заканчивается над панелью кнопок
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView)
            make.width.equalTo(scrollView)
        }
    
        
        contentView.addSubview(heroImageView)
        heroImageView.addSubview(imageGradient)
        contentView.addSubview(titleLabel)
        contentView.addSubview(ratingStack)
        contentView.addSubview(priceLabel)
        contentView.addSubview(specsStack)
        contentView.addSubview(descriptionTitleLabel)
        contentView.addSubview(descriptionLabel)
        
        
        heroImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(350) 
        }
        
        imageGradient.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(150) 
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(heroImageView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        
        ratingStack.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().inset(20)
        }
        
        priceLabel.snp.makeConstraints { make in
            make.centerY.equalTo(ratingStack)
            make.trailing.equalToSuperview().inset(20)
        }
        
        
        specsStack.snp.makeConstraints { make in
            make.top.equalTo(ratingStack.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(80)
        }
        
        
        descriptionTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(specsStack.snp.bottom).offset(30)
            make.leading.equalToSuperview().inset(20)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionTitleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-40) 
        }
        
        
        
        cartButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(20)
            make.width.height.equalTo(50)
        }
        
        buyButton.snp.makeConstraints { make in
            make.centerY.equalTo(cartButton)
            make.leading.equalTo(cartButton.snp.trailing).offset(16)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(50)
        }
        
        buyButton.addTarget(self, action: #selector(didTapBuy), for: .touchUpInside)
        cartButton.addTarget(self, action: #selector(didTapCart), for: .touchUpInside)
    }
    
    private func setupCustomBackButton() {
        let backBtn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
        backBtn.setImage(UIImage(systemName: "arrow.left", withConfiguration: config), for: .normal)
        backBtn.tintColor = .white
        backBtn.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        backBtn.layer.cornerRadius = 20
        backBtn.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        
        view.addSubview(backBtn)
        backBtn.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
            make.leading.equalToSuperview().offset(20)
            make.width.height.equalTo(40)
        }
    }

    private func configureData() {
        titleLabel.text = bike.name
        priceLabel.text = bike.formattedPrice
        
        if let image = UIImage(named: bike.image_url) {
            heroImageView.image = image
        }
        
        
        descriptionLabel.text = "Experience the thrill of the open road with the \(bike.name). Built for performance, this machine features state-of-the-art aerodynamics and a high-performance engine. Whether you're on the track or the street, it delivers unmatched power and control."
        
        
        configureSpecs()
    }
    
    private func configureSpecs() {
        specsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        
        let spec1 = createSpecBox(title: "Engine", value: "998 cc", icon: "bolt.fill")
        let spec2 = createSpecBox(title: "Power", value: "200 hp", icon: "gauge")
        let spec3 = createSpecBox(title: "Weight", value: "200 kg", icon: "scalemass.fill")
        
        specsStack.addArrangedSubview(spec1)
        specsStack.addArrangedSubview(spec2)
        specsStack.addArrangedSubview(spec3)
    }
    
    
    private func createSpecBox(title: String, value: String, icon: String) -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor(hex: "1E1E1E")
        container.layer.cornerRadius = 12
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor(white: 1, alpha: 0.05).cgColor
        
        let iconIV = UIImageView(image: UIImage(systemName: icon))
        iconIV.tintColor = UIColor(hex: "F4B400")
        iconIV.contentMode = .scaleAspectFit
        
        let valLabel = UILabel()
        valLabel.text = value
        valLabel.font = .systemFont(ofSize: 14, weight: .bold)
        valLabel.textColor = .white
        valLabel.textAlignment = .center
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 11, weight: .regular)
        titleLabel.textColor = .gray
        titleLabel.textAlignment = .center
        
        container.addSubview(iconIV)
        container.addSubview(valLabel)
        container.addSubview(titleLabel)
        
        iconIV.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.centerX.equalToSuperview()
            make.height.width.equalTo(20)
        }
        
        valLabel.snp.makeConstraints { make in
            make.top.equalTo(iconIV.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(valLabel.snp.bottom).offset(2)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-12)
        }
        
        return container
    }

    // MARK: - Actions

    @objc private func goBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func didTapBuy() {
        print("Buy tapped for \(bike.name)")
        CartViewModel.shared.addToCart(bike.toProduct())
        
        let cartVC = CartViewController()
        if let sheet = cartVC.sheetPresentationController {
            sheet.detents = [.large()]
        }
        present(cartVC, animated: true)
    }
    
    @objc private func didTapCart() {
        print("Added to cart: \(bike.name)")
        CartViewModel.shared.addToCart(bike.toProduct())
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        let alert = UIAlertController(title: "Added to Cart", message: "\(bike.name) is now in your cart.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension UILabel {
    func setLineHeight(lineHeight: CGFloat) {
        guard let text = self.text else { return }
        let attributeString = NSMutableAttributedString(string: text)
        let style = NSMutableParagraphStyle()
        style.lineSpacing = lineHeight
        attributeString.addAttribute(.paragraphStyle, value: style, range: NSMakeRange(0, attributeString.length))
        self.attributedText = attributeString
    }
}
