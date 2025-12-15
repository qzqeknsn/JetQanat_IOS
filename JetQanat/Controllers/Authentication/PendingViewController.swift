import UIKit
import SnapKit
import Combine

class PendingViewController: UIViewController {

    // MARK: - Components
    
    private let animationContainer: UIView = {
        let view = UIView()
        return view
    }()
    
    private let backgroundCircleLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor(hex: "FFB800").withAlphaComponent(0.2).cgColor
        layer.lineWidth = 8
        return layer
    }()
    
    private let rotatingCircleLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor(hex: "FFB800").cgColor
        layer.lineWidth = 8
        layer.lineCap = .round
        return layer
    }()
    
    private let hourglassImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "hourglass")
        iv.tintColor = UIColor(hex: "FFB800")
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Verification Pending"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "We're reviewing your documents.\nThis usually takes less than 24 hours."
        label.font = .systemFont(ofSize: 16)
        label.textColor = .gray
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let statusContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "1E2836")
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let exploreButton: UIButton = {
        let button = UIButton(type: .system)
        
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = UIColor(hex: "2A3544")
        config.baseForegroundColor = .white
        config.cornerStyle = .medium
        config.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0)
        
        var titleContainer = AttributeContainer()
        titleContainer.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        config.attributedTitle = AttributedString("Explore App (Limited Access)", attributes: titleContainer)
        
        button.configuration = config
        button.layer.cornerRadius = 16
        
        return button
    }()
    
    // MARK: - Lifecycle
    
    private let viewModel: AuthenticationViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Lifecycle
    
    init(viewModel: AuthenticationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        bindViewModel()
    }
    
    private func bindViewModel() {
        viewModel.$isAuthenticated
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isAuthenticated in
                if isAuthenticated {
                    self?.navigateToApp()
                }
            }
            .store(in: &cancellables)
    }
    
    private func navigateToApp() {
        if let window = view.window {
            window.rootViewController = MainTabBarController()
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let center = CGPoint(x: animationContainer.bounds.width / 2, y: animationContainer.bounds.height / 2)
        let radius = (animationContainer.bounds.width - 8) / 2
        
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: -CGFloat.pi / 2, endAngle: 1.5 * CGFloat.pi, clockwise: true)
        
        backgroundCircleLayer.path = path.cgPath
        rotatingCircleLayer.path = path.cgPath
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startAnimation()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = UIColor(hex: "0F1419")
        
        view.addSubview(animationContainer)
        animationContainer.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(60)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(120)
        }
        
        animationContainer.layer.addSublayer(backgroundCircleLayer)
        animationContainer.layer.addSublayer(rotatingCircleLayer)
        
        animationContainer.addSubview(hourglassImageView)
        hourglassImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(animationContainer.snp.bottom).offset(32)
            make.centerX.equalToSuperview()
        }
        
        view.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(32)
        }
        
        view.addSubview(statusContainer)
        let row1 = createStatusRow(icon: "checkmark.circle.fill", text: "Documents received", isComplete: true)
        let row2 = createStatusRow(icon: "hourglass", text: "Under review", isComplete: false) // Active but not complete
        let row3 = createStatusRow(icon: "circle", text: "Account verified", isComplete: false)
        
        let statusStack = UIStackView(arrangedSubviews: [row1, row2, row3])
        statusStack.axis = .vertical
        statusStack.spacing = 16
        
        statusContainer.addSubview(statusStack)
        statusStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        
        statusContainer.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        view.addSubview(exploreButton)
        exploreButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(40)
            make.leading.trailing.equalToSuperview().inset(32)
        }
    }
    
    private func createStatusRow(icon: String, text: String, isComplete: Bool) -> UIView {
        let container = UIView()
        
        let iv = UIImageView()
        iv.image = UIImage(systemName: icon)
        iv.tintColor = isComplete ? UIColor(hex: "FFB800") : .gray
        iv.contentMode = .scaleAspectFit
        
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 14)
        label.textColor = isComplete ? .white : .gray
        
        container.addSubview(iv)
        container.addSubview(label)
        
        iv.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        label.snp.makeConstraints { make in
            make.leading.equalTo(iv.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        container.snp.makeConstraints { make in
            make.height.equalTo(24)
        }
        
        return container
    }
    
    private func setupActions() {
        exploreButton.addTarget(self, action: #selector(didTapExplore), for: .touchUpInside)
    }
    
    private func startAnimation() {
        
        rotatingCircleLayer.strokeEnd = 0.7
        
        let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = 2
        rotation.isCumulative = true
        rotation.repeatCount = Float.infinity
        rotation.timingFunction = CAMediaTimingFunction(name: .linear) 
        
        animationContainer.layer.add(rotation, forKey: "rotationAnimation")
    }
    
    // MARK: - Actions
    
    @objc private func didTapExplore() {
         if let window = view.window {
            window.rootViewController = MainTabBarController()
            
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
        }
    }
}
