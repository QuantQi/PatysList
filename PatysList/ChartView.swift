import SwiftUI

struct ChartView: View {
    @State private var shoppingList: [ItemType] = CoreDataManager.shared.fetchPurchaseHistory()
    @State private var selectedItems: Set<UUID> = []
    
    // Access the system's color scheme (light or dark)
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationView {
            List {
                // Iterate over sorted shoppingList
                ForEach(shoppingList.sorted(by: { $0.quantity > $1.quantity })) { item in
                    HStack {
                        // Adjust the text color based on the system's color scheme
                        Text(item.name)
                            .foregroundColor(colorScheme == .dark ? .white : .black) // Dynamic color
                            .opacity(0.6)
                            .frame(width: 100, alignment: .leading)
                        
                        // Adjust the rectangle bar color based on the system's color scheme
                        Rectangle()
                            .foregroundColor(colorScheme == .dark ? .white : .black) // Dynamic color
                            .opacity(0.3)
                            .frame(width: CGFloat(Float(item.quantity) ?? 0), height: 20)
                        Spacer()
                        Text(item.quantity)
                            .foregroundColor(colorScheme == .dark ? .white : .black) // Dynamic color
                            .opacity(0.3)
                    }
                    .swipeActions {
                        // Swipe action to delete the item
                        Button(action: {
                            CoreDataManager.shared.deleteItemsWithName(as: item.name)
                            shoppingList.removeAll(where: { $0.id == item.id })
                        }) {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            // Set the title of the navigation view and adapt its color based on the color scheme
            .navigationTitle(
                Text("Purchase History")
                    .foregroundColor(colorScheme == .dark ? .white : .black) // Dynamic title color
            )
        }
    }
}

struct ChartView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ChartView()
                .preferredColorScheme(.light) // Preview in light mode
            ChartView()
                .preferredColorScheme(.dark) // Preview in dark mode
        }
    }
}
