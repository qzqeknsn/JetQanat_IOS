//
//  NotificationsViewModel.swift
//  JetQanat
//
//  Created by Zholdibay Abylay on 16.12.2025.
//

import Foundation
import Combine

class NotificationsViewModel: ObservableObject {
    @Published var notifications: [UserNotification] = []
    @Published var unreadCount: Int = 0
    
    init() {
        loadNotifications()
    }
    
    func loadNotifications() {
        
        updateUnreadCount()
    }
    
    func markAsRead(_ notification: UserNotification) {
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[index].isRead = true
            updateUnreadCount()
        }
    }
    
    func markAllAsRead() {
        for i in notifications.indices {
            notifications[i].isRead = true
        }
        updateUnreadCount()
    }
    
    func deleteNotification(_ notification: UserNotification) {
        notifications.removeAll { $0.id == notification.id }
        updateUnreadCount()
    }
    
    private func updateUnreadCount() {
        unreadCount = notifications.filter { !$0.isRead }.count
    }
    
    func generateSampleNotifications() {
        let samples: [UserNotification] = [
            UserNotification(
                type: .order,
                title: "Order Shipped",
                message: "Your order MH-JP-00123 has been shipped from Japan",
                timestamp: Date().addingTimeInterval(-3600)
            ),
            UserNotification(
                type: .rental,
                title: "Rental Reminder",
                message: "Your Yamaha R1 rental starts tomorrow",
                timestamp: Date().addingTimeInterval(-7200)
            ),
            UserNotification(
                type: .promotion,
                title: "New Arrivals",
                message: "Check out the latest Kawasaki models from Japan",
                timestamp: Date().addingTimeInterval(-86400)
            ),
            UserNotification(
                type: .system,
                title: "Welcome to Motor Hub",
                message: "Explore premium Japanese motorcycles and parts",
                timestamp: Date().addingTimeInterval(-172800)
            )
        ]
        
        self.notifications = samples
        updateUnreadCount()
    }
}
