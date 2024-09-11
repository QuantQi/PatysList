import SwiftUI

struct ContentView: View {
    @State private var shoppingList: [ItemType] = CoreDataManager.shared.fetchTempItems()
    @State private var newItem: String = ""
    @State private var quantity: String = ""
    
    // Access the system's color scheme (light or dark)
    @Environment(\.colorScheme) var colorScheme
    
    // Declare a focus state for the newItem TextField
    @FocusState private var isNewItemFocused: Bool

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    // TextField for item input
                    TextField("Enter item", text: $newItem)
                        .padding(.leading)
                        .focused($isNewItemFocused) // Attach the focus state to this TextField
                        .foregroundColor(colorScheme == .dark ? .white : .black) // Adjust text color based on color scheme
                    Spacer()
                    
                    // TextField for quantity input
                    TextField("1", text: $quantity)
                        .frame(width: 30, height: 30)
                        .foregroundColor(colorScheme == .dark ? .white : .black) // Adjust text color based on color scheme
                    
                    // Add item button
                    Button(action: {
                        addItem()
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 25))
                            .padding()
                            .foregroundColor(colorScheme == .dark ? .white : .gray) // Adjust button color
                    }
                }
                .background(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1)) // Adjust background color
                
                // Shopping list
                List {
                    ForEach($shoppingList) { $item in
                        HStack {
                            // 1. Radio button for checked status
                            Button(action: {
                                item.checked.toggle()
                                CoreDataManager.shared.updateTempItem(item: item) // Update temp db
                            }) {
                                Image(systemName: item.checked ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(item.checked ? (colorScheme == .dark ? .white : .black) : .gray) // Adjust checkmark color
                                    .padding()
                            }
                            
                            // 2. Item text
                            TextField(item.name, text: $item.name)
                                .foregroundColor(colorScheme == .dark ? .white : .gray) // Adjust text color based on color scheme
                            Spacer()
                            
                            // 3. Quantity text
                            TextField(item.quantity, text: $item.quantity)
                                .frame(width: 30, height: 30)
                                .foregroundColor(colorScheme == .dark ? .white : .black) // Adjust quantity text color
                        }
                    }
                    .onDelete { indexSet in
                        CoreDataManager.shared.deleteTempItem(i: shoppingList[indexSet.first!])
                        shoppingList.remove(atOffsets: indexSet)
                    }
                    .onMove { indices, newOffset in
                        shoppingList.move(fromOffsets: indices, toOffset: newOffset)
                    }
                }
                .listStyle(PlainListStyle())
                
                // Button to mark items as done
                Button(action: {
                    saveShoppingList(items: shoppingList.filter { $0.checked })
                    shoppingList.removeAll { $0.checked }
                }) {
                    HStack {
                        Text("Shopping done")
                    }
                    .padding()
                    .background(shoppingList.filter { $0.checked }.isEmpty ? Color.gray : (colorScheme == .dark ? Color.white : Color.black)) // Dynamic background color
                    .foregroundColor(colorScheme == .dark ? .black : .white) // Adjust text color
                    .cornerRadius(10)
                    .disabled(shoppingList.filter { $0.checked }.isEmpty)
                }
            }
            .navigationTitle("Paty's List")
            .navigationBarItems(trailing:
                NavigationLink(destination: ChartView()) {
                    Image(systemName: "chart.bar.fill")
                        .foregroundColor(colorScheme == .dark ? .white : .black) // Adjust navigation bar button color
                }
            )
            .onAppear {
                isNewItemFocused = true // Focus on the newItem TextField when the view appears
            }
        }
    }
    
    func addItem() {
        if !newItem.isEmpty {
            if quantity.isEmpty || Int(quantity) == 0 {
                quantity = "1"
            }

            let newItem = ItemType(id: UUID(), timestamp: Date(), name: newItem, quantity: quantity, checked: false, indexVal: shoppingList.count)
            shoppingList.append(newItem)
            CoreDataManager.shared.saveTempItem(i: newItem)
            
            self.newItem = ""
            self.quantity = ""
            
            // Refocus on the newItem TextField after adding an item
            isNewItemFocused = true
        }
    }
    
    func saveShoppingList(items: [ItemType]) {
        CoreDataManager.shared.saveItems(items: items)
        
        for i in items {
            CoreDataManager.shared.deleteTempItem(i: i)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .preferredColorScheme(.light)
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}
