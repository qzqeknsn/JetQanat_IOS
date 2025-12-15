//
//  Notification.swift
//  JetQanat
//
//  Created by Zholdibay Abylay on 16.12.2025.
//

import Foundation

enum NotificationType: String, Codable {
    case order = "order"
    case rental = "rental"
    case promotion = "promotion"
    case system = "system"
    
    var icon: String {
        switch self {
        case .order: return "shippingbox.fill"
        case .rental: return "bicycle"
        case .promotion: return "tag.fill"
        case .system: return "bell.fill"
        }
    }
    
    var color: String {
        switch self {
        case .order: return "10B981"
        case .rental: return "FFB800"
        case .promotion: return "FF6B6B"
        case .system: return "6366F1"
        }
    }
}

struct UserNotification: Identifiable, Codable {
    let id: UUID
    let type: NotificationType
    let title: String
    let message: String
    let timestamp: Date
    var isRead: Bool
    
    init(id: UUID = UUID(), type: NotificationType, title: String, message: String, timestamp: Date = Date(), isRead: Bool = false) {
        self.id = id
        self.type = type
        self.title = title
        self.message = message
        self.timestamp = timestamp
        self.isRead = isRead
    }
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
}
