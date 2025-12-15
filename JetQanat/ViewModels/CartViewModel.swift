import Foundation
import Combine
import CoreData

class CartViewModel: ObservableObject {
    @Published var cartItems: [CartItem] = []
    @Published var showCart: Bool = false
    @Published var orders: [Order] = []
    
    static let shared = CartViewModel()
    
    private var context: NSManagedObjectContext {
        return CoreDataManager.shared.context
    }
    
    init() {
        loadData()
    }
    
    private func loadData() {
        fetchCartItems()
        fetchOrders()
    }
    
    // MARK: - Core Data Fetching
    
    private func fetchCartItems() {
        let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "CartItemEntity")
        
        do {
            let results = try context.fetch(request)
            self.cartItems = results.map { entity in
                let id = entity.value(forKey: "productId") as? Int ?? 0
                let title = entity.value(forKey: "productTitle") as? String ?? "Unknown"
                let priceVal = entity.value(forKey: "productPriceValue") as? Double ?? 0.0
                let image = entity.value(forKey: "productImage") as? String ?? "placeholder"
                let cat = entity.value(forKey: "productCategory") as? String ?? "Parts"
                let qty = entity.value(forKey: "quantity") as? Int ?? 1
                
                let product = Product(id: id, title: title, price: "₸\(Int(priceVal).formatted())", priceValue: priceVal, category: cat, imageName: image, description: "")
                
                return CartItem(product: product, quantity: qty)
            }
        } catch {
            print("Error fetching cart: \(error)")
        }
    }
    
    private func fetchOrders() {
        let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "OrderEntity")
        
        
        do {
            let results = try context.fetch(request)
            self.orders = results.compactMap { entity in
                guard let id = entity.value(forKey: "id") as? UUID,
                      let code = entity.value(forKey: "orderCode") as? String,
                      let total = entity.value(forKey: "totalAmount") as? Double,
                      let statusRaw = entity.value(forKey: "status") as? String,
                      let status = OrderStatus(rawValue: statusRaw) else { return nil }
                
                return Order(id: id,
                             orderCode: code,
                             productTitles: ["Order #\(code.suffix(4))"],
                             totalAmount: total,
                             cashbackUsed: 0,
                             cashbackEarned: 0,
                             shippingAddress: "",
                             zipCode: "",
                             status: status,
                             estimatedArrival: Date(),
                             createdAt: Date())
            }.reversed()
        } catch {
            print("Error fetching orders: \(error)")
        }
    }
    
    // MARK: - Computed Properties
    
    var itemCount: Int {
        return cartItems.reduce(0) { $0 + $1.quantity }
    }
    
    var subtotal: Double {
        return cartItems.filter { $0.isSelected }.reduce(0) { $0 + $1.totalPrice }
    }
    
    var formattedSubtotal: String {
        return "₸\(Int(subtotal).formatted())"
    }
    
    var totalCashback: Double {
        return cartItems.filter { $0.isSelected }.reduce(0) { $0 + $1.totalCashback }
    }
    
    var formattedTotalCashback: String {
        return "₸\(Int(totalCashback).formatted())"
    }
    
    var total: Double {
        return subtotal
    }
    
    var formattedTotal: String {
        return "₸\(Int(total).formatted())"
    }
    
    // MARK: - Actions
    
    func addToCart(_ product: Product, quantity: Int = 1) {
        
        let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "CartItemEntity")
        request.predicate = NSPredicate(format: "productId == %d", Int64(product.id))
        
        do {
            let results = try context.fetch(request)
            if let existingEntity = results.first {
                // Update
                let currentQty = existingEntity.value(forKey: "quantity") as? Int ?? 0
                existingEntity.setValue(currentQty + quantity, forKey: "quantity")
            } else {
                // Create New
                guard let entity = NSEntityDescription.entity(forEntityName: "CartItemEntity", in: context) else { return }
                let newItem = NSManagedObject(entity: entity, insertInto: context)
                newItem.setValue(product.id, forKey: "productId")
                newItem.setValue(quantity, forKey: "quantity")
                newItem.setValue(product.title, forKey: "productTitle")
                newItem.setValue(product.priceValue, forKey: "productPriceValue")
                newItem.setValue(product.imageName, forKey: "productImage")
                newItem.setValue(product.category, forKey: "productCategory")
            }
            CoreDataManager.shared.saveContext()
            fetchCartItems() 
        } catch {
            print("Error adding to cart: \(error)")
        }
    }
    
    func removeFromCart(_ item: CartItem) {
        let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "CartItemEntity")
        request.predicate = NSPredicate(format: "productId == %d", Int64(item.product.id))
        
        do {
            let results = try context.fetch(request)
            if let entity = results.first {
                context.delete(entity)
                CoreDataManager.shared.saveContext()
                fetchCartItems()
            }
        } catch {
            print("Error removing: \(error)")
        }
    }
    
    func updateQuantity(for item: CartItem, quantity: Int) {
        if quantity <= 0 {
            removeFromCart(item)
            return
        }
        
        let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "CartItemEntity")
        request.predicate = NSPredicate(format: "productId == %d", Int64(item.product.id))
        
        do {
            let results = try context.fetch(request)
            if let entity = results.first {
                entity.setValue(quantity, forKey: "quantity")
                CoreDataManager.shared.saveContext()
                fetchCartItems()
            }
        } catch {
            print("Error updating quantity: \(error)")
        }
    }
    
    func toggleSelection(for item: CartItem) {
        if let index = cartItems.firstIndex(of: item) {
            cartItems[index].isSelected.toggle()
        }
    }
    
    func selectAll(isSelected: Bool) {
        for i in 0..<cartItems.count {
            cartItems[i].isSelected = isSelected
        }
    }
    
    func clearCart() {
        // Delete all
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CartItemEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            try context.execute(deleteRequest)
            CoreDataManager.shared.saveContext()
            fetchCartItems()
        } catch {
            print("Error clearing cart: \(error)")
        }
    }
    
    func checkout() {
        let selectedItems = cartItems.filter { $0.isSelected }
        guard !selectedItems.isEmpty else { return }
        
        
        guard let orderEntityDef = NSEntityDescription.entity(forEntityName: "OrderEntity", in: context) else { return }
        let orderEntity = NSManagedObject(entity: orderEntityDef, insertInto: context)
        
        let orderId = UUID()
        let code = Order.generateOrderCode()
        
        orderEntity.setValue(orderId, forKey: "id")
        orderEntity.setValue(code, forKey: "orderCode")
        orderEntity.setValue(total, forKey: "totalAmount")
        orderEntity.setValue("Processing", forKey: "status")
        orderEntity.setValue("Product", forKey: "type")
        orderEntity.setValue(Date(), forKey: "createdAt")
        
        
        for item in selectedItems {
            let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "CartItemEntity")
            request.predicate = NSPredicate(format: "productId == %d", Int64(item.product.id))
            if let result = try? context.fetch(request).first {
                context.delete(result)
            }
        }
        
        
        CoreDataManager.shared.saveContext()
        
        
        fetchCartItems()
        fetchOrders()
        
        
        UserViewModel.shared.refreshCashback()
    }
}
