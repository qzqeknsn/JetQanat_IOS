import UIKit
import SnapKit
import Combine

class CartViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel = CartViewModel.shared
    private var cancellables = Set<AnyCancellable>()
    private var isCartTab: Bool = true {
        didSet { updateTabState() }
    }
    
    // MARK: - UI Elements
    
    private let headerView = UIView()
    
    
    private let segmentedContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "2C2C2E")
        view.layer.cornerRadius = 8
        return view
    }()
    
    private lazy var cartSegmentButton = createSegmentButton(title: "CART", isSelected: true)
    private lazy var purchasesSegmentButton = createSegmentButton(title: "PURCHASES", isSelected: false)
    
    private let closeButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
        btn.setImage(UIImage(systemName: "xmark", withConfiguration: config), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor(white: 1, alpha: 0.1)
        btn.layer.cornerRadius = 15
        return btn
    }()
    
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .grouped)
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.register(CartItemCell.self, forCellReuseIdentifier: CartItemCell.reuseIdentifier)
        tv.register(OrderCell.self, forCellReuseIdentifier: OrderCell.reuseIdentifier)
        tv.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        return tv
    }()
    
    
    private let bottomBar: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "1C1C1E")
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.shadowOffset = CGSize(width: 0, height: -3)
        view.layer.shadowRadius = 10
        return view
    }()
    
    private let totalLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .gray
        label.text = "Total:"
        return label
    }()
    
    private let totalPriceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private let buyButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = UIColor.accentGold
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        btn.layer.cornerRadius = 12
        return btn
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupActions()
        bindViewModel()
    }
    
    // MARK: - Setup
    
    private func setupLayout() {
        view.backgroundColor = .black
        
        
        view.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(100)
        }
        
        headerView.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.leading.equalTo(20)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.width.height.equalTo(30)
        }
        
        headerView.addSubview(segmentedContainer)
        segmentedContainer.snp.makeConstraints { make in
            make.centerY.equalTo(closeButton)
            make.centerX.equalToSuperview()
            make.width.equalTo(240)
            make.height.equalTo(36)
        }
        
        let stack = UIStackView(arrangedSubviews: [cartSegmentButton, purchasesSegmentButton])
        stack.distribution = .fillEqually
        segmentedContainer.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        
        view.addSubview(bottomBar)
        bottomBar.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(100)
        }
        
        bottomBar.addSubview(totalLabel)
        bottomBar.addSubview(totalPriceLabel)
        bottomBar.addSubview(buyButton)
        
        buyButton.snp.makeConstraints { make in
            make.trailing.equalTo(-20)
            make.top.equalTo(16)
            make.height.equalTo(50)
            make.width.equalTo(140)
        }
        
        totalLabel.snp.makeConstraints { make in
            make.leading.equalTo(20)
            make.top.equalTo(buyButton).offset(4)
        }
        
        totalPriceLabel.snp.makeConstraints { make in
            make.leading.equalTo(totalLabel)
            make.top.equalTo(totalLabel.snp.bottom).offset(2)
        }
        
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(bottomBar.snp.top)
        }
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func createSegmentButton(title: String, isSelected: Bool) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(isSelected ? .black : .gray, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 13, weight: .bold)
        btn.backgroundColor = isSelected ? .white : .clear
        btn.layer.cornerRadius = 6
        return btn
    }
    
    private func setupActions() {
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        cartSegmentButton.addTarget(self, action: #selector(didTapCartTab), for: .touchUpInside)
        purchasesSegmentButton.addTarget(self, action: #selector(didTapPurchasesTab), for: .touchUpInside)
        buyButton.addTarget(self, action: #selector(didTapCheckout), for: .touchUpInside)
    }
    
    private func bindViewModel() {
        viewModel.$cartItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self, self.isCartTab else { return }
                self.tableView.reloadData()
                self.updateTotals()
            }
            .store(in: &cancellables)
        
        viewModel.$orders
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self, !self.isCartTab else { return }
                self.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    private func updateTabState() {
        // UI Updates for Tabs
        UIView.animate(withDuration: 0.2) {
            self.cartSegmentButton.backgroundColor = self.isCartTab ? .white : .clear
            self.cartSegmentButton.setTitleColor(self.isCartTab ? .black : .gray, for: .normal)
            
            self.purchasesSegmentButton.backgroundColor = !self.isCartTab ? .white : .clear
            self.purchasesSegmentButton.setTitleColor(!self.isCartTab ? .black : .gray, for: .normal)
            
            self.bottomBar.alpha = self.isCartTab ? 1.0 : 0.0
        }
        
        tableView.reloadData()
        
        if isCartTab {
            updateTotals()
        }
    }
    
    private func updateTotals() {
        let count = viewModel.cartItems.filter { $0.isSelected }.count
        buyButton.setTitle("BUY (\(count))", for: .normal)
        totalPriceLabel.text = viewModel.formattedTotal 
        
        
        buyButton.isEnabled = count > 0
        buyButton.alpha = count > 0 ? 1.0 : 0.5
    }
    
    // MARK: - Actions
    @objc private func didTapClose() { dismiss(animated: true) }
    @objc private func didTapCartTab() { isCartTab = true }
    @objc private func didTapPurchasesTab() { isCartTab = false }
    
    @objc private func didTapCheckout() {
        let paymentVC = PaymentSelectionViewController()
        paymentVC.modalPresentationStyle = .overFullScreen
        paymentVC.modalTransitionStyle = .crossDissolve
        
        paymentVC.onMethodSelected = { [weak self] method in
            if method == "Card" {
                
                let cardsVC = PaymentMethodsViewController()
                if let sheet = cardsVC.sheetPresentationController {
                    sheet.detents = [.medium(), .large()]
                }
                self?.present(cardsVC, animated: true)
            } else {
                
                self?.performCheckout(method: method)
            }
        }
        
        present(paymentVC, animated: true)
    }
    
    private func performCheckout(method: String) {
        viewModel.checkout()
        let alert = UIAlertController(title: "Success", message: "Order placed via \(method)!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func didTapSelectAll() {
        let allSelected = viewModel.cartItems.allSatisfy { $0.isSelected }
        viewModel.selectAll(isSelected: !allSelected)
    }
}

// MARK: - UITableViewDataSource
extension CartViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return isCartTab ? 1 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isCartTab ? viewModel.cartItems.count : viewModel.orders.count
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard isCartTab, !viewModel.cartItems.isEmpty else { return nil }
        
        let header = UIView()
        header.backgroundColor = .black
        
        let btn = UIButton(type: .custom)
        let allSelected = viewModel.cartItems.allSatisfy { $0.isSelected }
        let icon = allSelected ? "checkmark.square.fill" : "square"
        btn.setImage(UIImage(systemName: icon), for: .normal)
        btn.tintColor = allSelected ? .accentGold : .gray
        btn.setTitle(" Select All", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.addTarget(self, action: #selector(didTapSelectAll), for: .touchUpInside)
        
        header.addSubview(btn)
        btn.snp.makeConstraints { make in
            make.leading.equalTo(20)
            make.centerY.equalToSuperview()
        }
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (isCartTab && !viewModel.cartItems.isEmpty) ? 40 : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isCartTab {
            let cell = tableView.dequeueReusableCell(withIdentifier: CartItemCell.reuseIdentifier, for: indexPath) as! CartItemCell
            let item = viewModel.cartItems[indexPath.row]
            cell.configure(with: item)
            
            cell.onToggleSelection = { [weak self] in
                self?.viewModel.toggleSelection(for: item)
            }
            cell.onQuantityChange = { [weak self] newQty in
                self?.viewModel.updateQuantity(for: item, quantity: newQty)
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: OrderCell.reuseIdentifier, for: indexPath) as! OrderCell
            let order = viewModel.orders[indexPath.row]
            cell.configure(with: order)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return isCartTab ? 140 : 120
    }
}

