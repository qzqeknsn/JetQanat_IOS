import UIKit
import SnapKit
import CoreData

// MARK: - Profile Stubs

class PurchaseHistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let tableView = UITableView()
    private var orders: [OrderEntity] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadOrders()
    }
    
    private func setupUI() {
        title = "Purchase History"
        view.backgroundColor = UIColor(hex: "0A0A0A")
        navigationController?.navigationBar.tintColor = .white
        
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(OrderHistoryCell.self, forCellReuseIdentifier: "OrderCell")
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func loadOrders() {
        let context = CoreDataManager.shared.context
        let request: NSFetchRequest<OrderEntity> = OrderEntity.fetchRequest()
        request.predicate = NSPredicate(format: "type == %@ OR type == nil", "Product")
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        do {
            orders = try context.fetch(request)
            tableView.reloadData()
        } catch {
            print("Failed to fetch orders: \(error)")
        }
    }
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if orders.isEmpty { return 1 }
        return orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if orders.isEmpty {
            let cell = UITableViewCell()
            cell.backgroundColor = .clear
            cell.textLabel?.text = "No purchases yet."
            cell.textLabel?.textColor = .gray
            cell.textLabel?.textAlignment = .center
            cell.selectionStyle = .none
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCell", for: indexPath) as! OrderHistoryCell
        let order = orders[indexPath.row]
        cell.configure(with: order)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return orders.isEmpty ? 200 : 100
    }
}

class OrderHistoryCell: UITableViewCell {
    
    private let containerView = UIView()
    private let codeLabel = UILabel()
    private let priceLabel = UILabel()
    private let statusLabel = UILabel()
    private let dateLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        containerView.backgroundColor = UIColor(hex: "1C1C1E")
        containerView.layer.cornerRadius = 12
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        codeLabel.font = .systemFont(ofSize: 16, weight: .bold)
        codeLabel.textColor = .white
        containerView.addSubview(codeLabel)
        codeLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(16)
        }
        
        priceLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        priceLabel.textColor = UIColor(hex: "FFB800")
        containerView.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(16)
        }
        
        statusLabel.font = .systemFont(ofSize: 14)
        statusLabel.textColor = .green
        containerView.addSubview(statusLabel)
        statusLabel.snp.makeConstraints { make in
            make.top.equalTo(codeLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().inset(16)
        }
        
        dateLabel.font = .systemFont(ofSize: 12)
        dateLabel.textColor = .gray
        containerView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(statusLabel.snp.bottom).offset(4)
            make.leading.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(16)
        }
    }
    
    func configure(with order: OrderEntity) {
        codeLabel.text = "Order #\(order.orderCode ?? "N/A")"
        priceLabel.text = "₸\(Int(order.totalAmount).formatted())"
        statusLabel.text = "Status: \(order.status?.capitalized ?? "Processing")"
        
        if let date = order.createdAt {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            dateLabel.text = formatter.string(from: date)
        } else {
            dateLabel.text = ""
        }
    }
}

class ServiceHistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let tableView = UITableView()
    private var records: [OrderEntity] = [] 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadRecords()
    }
    
    private func setupUI() {
        title = "Service History"
        view.backgroundColor = UIColor(hex: "0A0A0A")
        navigationController?.navigationBar.tintColor = .white
        
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ServiceHistoryCell.self, forCellReuseIdentifier: "ServiceCell")
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func loadRecords() {
        let context = CoreDataManager.shared.context
        let request: NSFetchRequest<OrderEntity> = OrderEntity.fetchRequest()
        request.predicate = NSPredicate(format: "type == %@", "Service")
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        do {
            records = try context.fetch(request)
            tableView.reloadData()
        } catch {
            print("Failed to fetch service history: \(error)")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if records.isEmpty { return 1 }
        return records.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if records.isEmpty {
            let cell = UITableViewCell()
            cell.backgroundColor = .clear
            cell.textLabel?.text = "No service requests yet."
            cell.textLabel?.textColor = .gray
            cell.textLabel?.textAlignment = .center
            cell.selectionStyle = .none
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceCell", for: indexPath) as! ServiceHistoryCell
        let record = records[indexPath.row]
        cell.configure(with: record)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return records.isEmpty ? 200 : 100
    }
}

class ServiceHistoryCell: UITableViewCell {
    
    private let containerView = UIView()
    private let typeLabel = UILabel()
    private let dateLabel = UILabel()
    private let costLabel = UILabel()
    private let statusBadge = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        containerView.backgroundColor = UIColor(hex: "1C1C1E")
        containerView.layer.cornerRadius = 12
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        typeLabel.font = .systemFont(ofSize: 16, weight: .bold)
        typeLabel.textColor = .white
        containerView.addSubview(typeLabel)
        typeLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(16)
        }
        
        costLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        costLabel.textColor = UIColor(hex: "FFB800")
        containerView.addSubview(costLabel)
        costLabel.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(16)
        }
        
        dateLabel.font = .systemFont(ofSize: 14)
        dateLabel.textColor = .gray
        containerView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(typeLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().inset(16)
        }
        
        statusBadge.font = .systemFont(ofSize: 12, weight: .medium)
        statusBadge.textColor = .green
        statusBadge.textAlignment = .right
        containerView.addSubview(statusBadge)
        statusBadge.snp.makeConstraints { make in
            make.bottom.trailing.equalToSuperview().inset(16)
        }
    }
    
    func configure(with record: OrderEntity) {
        typeLabel.text = record.orderCode ?? "Service"
        costLabel.text = "₸\(Int(record.totalAmount).formatted())"
        statusBadge.text = "● \(record.status ?? "Requested")"
        
        if let date = record.createdAt {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            dateLabel.text = formatter.string(from: date)
        } else {
            dateLabel.text = ""
        }
    }
}

class OrderTrackingViewController: UIViewController {
    
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let statusLabel = UILabel()
    private let timelineStack = UIStackView()
    private let mapPlaceholder = UIView()
    
    private var latestOrder: OrderEntity?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadLatestOrder()
    }
    
    private func setupUI() {
        title = "Order Tracking"
        view.backgroundColor = UIColor(hex: "0A0A0A")
        navigationController?.navigationBar.tintColor = .white
        
        mapPlaceholder.backgroundColor = UIColor(hex: "1C1C1E")
        mapPlaceholder.layer.cornerRadius = 16
        view.addSubview(mapPlaceholder)
        mapPlaceholder.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(200)
        }
        
        let mapIcon = UIImageView(image: UIImage(systemName: "map.fill"))
        mapIcon.tintColor = .darkGray
        mapPlaceholder.addSubview(mapIcon)
        mapIcon.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(50)
        }
        
        let mapLabel = UILabel()
        mapLabel.text = "Live Tracking Map (Demo)"
        mapLabel.textColor = .gray
        mapPlaceholder.addSubview(mapLabel)
        mapLabel.snp.makeConstraints { make in
            make.top.equalTo(mapIcon.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        
        containerView.backgroundColor = UIColor(hex: "1C1C1E")
        containerView.layer.cornerRadius = 20
        view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.top.equalTo(mapPlaceholder.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.lessThanOrEqualToSuperview().inset(40)
        }
        
        titleLabel.text = "Tracking #"
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .white
        
        statusLabel.text = "Searching..."
        statusLabel.font = .systemFont(ofSize: 16, weight: .medium)
        statusLabel.textColor = UIColor(hex: "FFB800")
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(statusLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(20)
        }
        
        statusLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalToSuperview().inset(20)
        }
        
        timelineStack.axis = .vertical
        timelineStack.spacing = 0
        containerView.addSubview(timelineStack)
        timelineStack.snp.makeConstraints { make in
            make.top.equalTo(statusLabel.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(20)
        }
    }
    
    private func loadLatestOrder() {
        let context = CoreDataManager.shared.context
        let request: NSFetchRequest<OrderEntity> = OrderEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        request.fetchLimit = 1
        
        do {
            let results = try context.fetch(request)
            if let order = results.first {
                self.latestOrder = order
                updateUI(with: order)
            } else {
                statusLabel.text = "No active orders found"
                titleLabel.text = "No Orders"
                timelineStack.isHidden = true
            }
        } catch {
            print("Error loading latest order: \(error)")
        }
    }
    
    private func updateUI(with order: OrderEntity) {
        titleLabel.text = "Tracking #\(order.orderCode ?? "N/A")"
        statusLabel.text = "Estimated Delivery: 2 Days"
        
        timelineStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let steps = ["Order Placed", "Confirmed", "Shipped", "Out for Delivery", "Delivered"]
        let status = order.status?.lowercased() ?? "processing"
        
        var completedIndex = 1
        if status == "shipped" { completedIndex = 2 }
        if status == "delivered" { completedIndex = 4 }
        
        for (index, step) in steps.enumerated() {
            let isCompleted = index <= completedIndex
            let isLast = index == steps.count - 1
            let view = createTimelineStep(title: step, isCompleted: isCompleted, isLast: isLast)
            timelineStack.addArrangedSubview(view)
        }
    }
    
    private func createTimelineStep(title: String, isCompleted: Bool, isLast: Bool) -> UIView {
        let view = UIView()
        
        let dot = UIView()
        dot.backgroundColor = isCompleted ? UIColor(hex: "FFB800") : .darkGray
        dot.layer.cornerRadius = 6
        view.addSubview(dot)
        dot.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.width.height.equalTo(12)
        }
        
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 14, weight: isCompleted ? .semibold : .regular)
        label.textColor = isCompleted ? .white : .gray
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.leading.equalTo(dot.snp.trailing).offset(12)
            make.centerY.equalTo(dot)
        }
        
        if !isLast {
            let line = UIView()
            line.backgroundColor = isCompleted ? UIColor(hex: "FFB800") : .darkGray
            view.addSubview(line)
            line.snp.makeConstraints { make in
                make.centerX.equalTo(dot)
                make.top.equalTo(dot.snp.bottom).offset(4)
                make.width.equalTo(2)
                make.height.equalTo(30)
                make.bottom.equalToSuperview().inset(4)
            }
        } else {
            let dummy = UIView()
            view.addSubview(dummy)
            dummy.snp.makeConstraints { make in
                make.top.equalTo(dot.snp.bottom).offset(4)
                make.bottom.equalToSuperview().inset(12)
            }
        }
        
        return view
    }
}

class AccountSettingsViewController: UIViewController {
    override func viewDidLoad() { super.viewDidLoad(); view.backgroundColor = UIColor(hex: "0A0A0A"); title = "Account Settings" }
}



class HelpSupportViewController: UIViewController {
    override func viewDidLoad() { super.viewDidLoad(); view.backgroundColor = UIColor(hex: "0A0A0A"); title = "Help & Support" }
}

class SecurityPrivacyViewController: UIViewController {
    override func viewDidLoad() { super.viewDidLoad(); view.backgroundColor = UIColor(hex: "0A0A0A"); title = "Security & Privacy" }
}
