//
//  ContentView.swift
//  iExpense
//
//  Created by Jordi Rivera Lizarralde on 28/7/21.
//

import SwiftUI

// Represents a single expense
// Identifiable: this item can be identified uniquely
// Must have an id. If not is going to complain
// Codable: In order to archive objects we need the codable
struct ExpenseItem: Identifiable, Codable {
    // Ensure each item is unique by generating a UUID
    let id = UUID()
    
    let name: String
    let type: String
    let amount: Int
}
// Array of those expense items
class Expenses: ObservableObject {
    // Published makes sure change announcements get sent whenever the items array gets modified.
    @Published var items = [ExpenseItem](){
        didSet {
            //  Create an instance of JSONEncoder that will do the work of converting our data to JSON
            let encoder = JSONEncoder()
            // Try encoding our items array
            if let encoded = try? encoder.encode(items){
                // Write that to UserDefaults using the key “Items”.
                UserDefaults.standard.set(encoded, forKey: "Items")
            }
        }
    }
    init() {
        // Attempt to read the “Items” key from UserDefaults.
        if let items = UserDefaults.standard.data(forKey: "Items") {
            // Create an instance of JSONDecoder
            let decoder = JSONDecoder()
            // Ask the decoder to convert the data we received from UserDefaults into an array of ExpenseItem objects.
            if let decoded = try? decoder.decode([ExpenseItem].self, from: items){
                // If that worked, assign the resulting array to items and exit.
                self.items = decoded
                return
            }
        }
        // Otherwise, set items to be an empty array.
        self.items = []
    }
}
// Modify the style of expenses depending on price
struct style: ViewModifier {
    var amount: Int
    
    func body(content: Content) -> some View {
        if amount < 10 {
            return content.foregroundColor(.red)
        }
        else if amount < 100 {
            return content.foregroundColor(.green)
        }
        else if amount > 100{
            return content.foregroundColor(.blue)
        }
        else {
            return content.foregroundColor(.black)
        }
    }
}
struct ContentView: View {
    // Watch the object for any change announcements
    @ObservedObject var expenses = Expenses()
    
    // Track whether or not AddView is being shown
    @State private var showingAddExpense = false
    var body: some View {
        NavigationView {
            // List of items
            List {
                // We don't need id: \.id because expenses is Identifiable and SWIFT knows there is an id
                // Title and Subtitle on the left, and more information on the right.
                ForEach(expenses.items){ item in
                    // Make sure all the information looks good on screen
                    HStack {
                        // Show the expense name and type
                        VStack(alignment: .leading) {
                            Text(item.name)
                                .font(.headline)
                            Text(item.type)
                        }
                        // Spacer
                        Spacer()
                        // Expense amount.
                        Text("$\(item.amount)")
                            // Apply color to amount depending on the price
                            .modifier(style(amount: item.amount))
                    }
                }
                // Call the function to delete elements of the list
                .onDelete(perform: removeItems)
            }
            // Title of the app
            .navigationBarTitle("iExpense")
            // Create button to add expenses
            .navigationBarItems(trailing:
                Button(action: {
                    // Whenever we press the button we show the add expense view
                    self.showingAddExpense = true
                }) {
                    // Make the button be a SF symbol of a plus
                    Image(systemName: "plus")
                }
            )
            .sheet(isPresented: $showingAddExpense) {
                // Show an AddView here
                AddView(expenses: self.expenses)
            }
            // Add an Edit/Done button
            .navigationBarItems(leading: EditButton())
        }
    }
    // function to remove elements of the list
    func removeItems(at offsets: IndexSet){
        expenses.items.remove(atOffsets: offsets)
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
