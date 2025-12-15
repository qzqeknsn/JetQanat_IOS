import UIKit
import SnapKit
import Combine



// MARK: - 2. Main Controller

class FilterViewController: UIViewController {
    
    // MARK: - Properties
  
    private let viewModel: MarketplaceViewModel
    
    // MARK: - UI Elements
    private let titleLabel = UILabel.make(text: "Filters", font: .boldSystemFont(ofSize: 18))
    private let clearButton = UIButton.makeText(text: "Clear All", color: .accentRed, bg: .cardBg)
    private let applyButton = UIButton.makeText(text: "Apply", color: .accentRed, bg: .cardBg)
    
    private let scrollView = UIScrollView()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        return stack
    }()
    
    // MARK: - Init
    init(viewModel: MarketplaceViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupContent()
    }
    
    // MARK: - Layout
    private func setupLayout() {
        view.backgroundColor = .darkBg
        
        let header = UIView()
        view.addSubview(header)
        header.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(60)
        }
        
        header.addSubview(clearButton)
        header.addSubview(titleLabel)
        header.addSubview(applyButton)
        
        clearButton.snp.makeConstraints { make in make.leading.equalTo(16); make.centerY.equalToSuperview() }
        titleLabel.snp.makeConstraints { make in make.center.equalToSuperview() }
        applyButton.snp.makeConstraints { make in make.trailing.equalTo(-16); make.centerY.equalToSuperview() }
        
        clearButton.addTarget(self, action: #selector(didTapClear), for: .touchUpInside)
        applyButton.addTarget(self, action: #selector(didTapApply), for: .touchUpInside)
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(header.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        scrollView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
            make.width.equalTo(scrollView).offset(-32)
        }
    }
    
    // MARK: - Content Builder
    private func setupContent() {
        addSection(title: "Price Range", content: createPriceSlider())
        
        let brandsGrid = createGrid(items: MarketplaceViewModel.motorcycleBrands) { [weak self] title in
            self?.viewModel.toggleBrand(title)
        }
        addSection(title: "Brands", content: brandsGrid)
        
        let stylesGrid = createGrid(items: MarketplaceViewModel.ridingStyles) { [weak self] title in
            self?.viewModel.toggleRidingStyle(title)
        }
        addSection(title: "Riding Style", content: stylesGrid)
    }
    
    // MARK: - Helpers
    private func addSection(title: String, content: UIView) {
        let label = UILabel.make(text: title, font: .boldSystemFont(ofSize: 18))
        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(content)
        stackView.setCustomSpacing(12, after: label)
    }
    
    private func createGrid(items: [String], action: @escaping (String) -> Void) -> UIView {
        let vStack = UIStackView()
        vStack.axis = .vertical
        vStack.spacing = 10
        
        let pairs = stride(from: 0, to: items.count, by: 2).map {
            Array(items[$0 ..< min($0 + 2, items.count)])
        }
        
        for pair in pairs {
            let hStack = UIStackView()
            hStack.spacing = 10
            hStack.distribution = .fillEqually
            
            for item in pair {
                let btn = FilterButton(title: item, icon: nil)
                btn.snp.makeConstraints { make in make.height.equalTo(44) }
                
                let uiAction = UIAction { _ in
                    btn.isToggled.toggle()
                    action(item)
                }
                btn.addAction(uiAction, for: .touchUpInside)
                
                hStack.addArrangedSubview(btn)
            }
            if pair.count < 2 { hStack.addArrangedSubview(UIView()) }
            vStack.addArrangedSubview(hStack)
        }
        return vStack
    }
    
    private func createPriceSlider() -> UIView {
        let container = UIView()
        container.backgroundColor = .cardBg
        container.layer.cornerRadius = 12
        container.snp.makeConstraints { $0.height.equalTo(80) }
        
        let slider = UISlider()
        slider.minimumTrackTintColor = .accentRed
        slider.thumbTintColor = .white
        slider.value = 0.5
        
        let minLabel = UILabel.make(text: "₸ 0", font: .boldSystemFont(ofSize: 12), color: .accentRed)
        let maxLabel = UILabel.make(text: "₸ 15M", font: .boldSystemFont(ofSize: 12), color: .accentRed)
        
        container.addSubview(slider)
        container.addSubview(minLabel)
        container.addSubview(maxLabel)
        
        slider.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(12)
        }
        minLabel.snp.makeConstraints { make in
            make.top.equalTo(slider.snp.bottom).offset(4)
            make.leading.equalTo(slider)
        }
        maxLabel.snp.makeConstraints { make in
            make.top.equalTo(slider.snp.bottom).offset(4)
            make.trailing.equalTo(slider)
        }
        return container
    }
    
    // MARK: - Actions
    @objc private func didTapApply() { dismiss(animated: true) }
    @objc private func didTapClear() { viewModel.clearAllFilters(); dismiss(animated: true) }
}

// MARK: - 3. Helper Classes

class FilterButton: UIButton {
    
    var isToggled: Bool = false {
        didSet {
            if isToggled {
                layer.borderColor = UIColor.white.cgColor
                layer.borderWidth = 1
            } else {
                layer.borderWidth = 0
            }
        }
    }
    
    init(title: String, icon: String?) {
        super.init(frame: .zero)
        
        backgroundColor = .cardBg
        layer.cornerRadius = 8
        
        setTitle(title, for: .normal)
        setTitleColor(.white, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 14)
        
        if let icon = icon {
            setImage(UIImage(systemName: icon), for: .normal)
            tintColor = .white
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
}
