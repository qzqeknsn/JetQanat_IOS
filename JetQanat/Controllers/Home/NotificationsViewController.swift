//
//  NotificationsViewController.swift
//  JetQanat
//
//  Created by Zholdibay Abylay on 16.12.2025.
//

import UIKit
import SnapKit
import Combine

class NotificationsViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel = NotificationsViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .clear
        tv.separatorStyle = .singleLine
        tv.separatorColor = .darkGray
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "NotificationCell")
        return tv
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No notifications"
        label.textColor = .gray
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        
        // For demo purposes, generate samples if empty
        if viewModel.notifications.isEmpty {
            viewModel.generateSampleNotifications()
        }
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = UIColor(hex: "0A0A0A")
        title = "Notifications"
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(hex: "0A0A0A")
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Read All", style: .plain, target: self, action: #selector(markAllRead))
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        view.addSubview(emptyLabel)
        emptyLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
    }
    
    private func bindViewModel() {
        viewModel.$notifications
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notifications in
                self?.emptyLabel.isHidden = !notifications.isEmpty
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    @objc private func markAllRead() {
        viewModel.markAllAsRead()
    }
}

// MARK: - TableView
extension NotificationsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath)
        let notification = viewModel.notifications[indexPath.row]
        
        cell.backgroundColor = notification.isRead ? .clear : UIColor(hex: "1A1A1A")
        cell.textLabel?.textColor = .white
        cell.detailTextLabel?.textColor = .gray
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.numberOfLines = 0
        cell.selectionStyle = .none
        
        // Using standard cell style for simplicity, custom cell recommended for better UI
        cell.textLabel?.text = notification.title
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        let dateString = dateFormatter.string(from: notification.timestamp)
        
        cell.detailTextLabel?.text = "\(notification.message)\n\(dateString)"
        
        // Icon based on type
        var iconName = "bell.fill"
        switch notification.type {
        case .order: iconName = "shippingbox.fill"
        case .rental: iconName = "calendar"
        case .promotion: iconName = "star.fill"
        case .system: iconName = "exclamationmark.circle.fill"
        }
        cell.imageView?.image = UIImage(systemName: iconName)
        cell.imageView?.tintColor = notification.isRead ? .gray : UIColor(hex: "FFB800")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notification = viewModel.notifications[indexPath.row]
        viewModel.markAsRead(notification)
        // Navigate or expand if needed
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let notification = viewModel.notifications[indexPath.row]
            viewModel.deleteNotification(notification)
        }
    }
}
