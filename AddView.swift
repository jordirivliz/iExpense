//
//  AddView.swift
//  iExpense
//
//  Created by Jordi Rivera Lizarralde on 2/8/21.
//

import SwiftUI

struct AddView: View {
    // Property to dismiss second view
    @Environment(\.presentationMode) var presentationMode
    // Share the existing instance from ContentView.
    // Add a property to AddView to store an Expenses object.
    @ObservedObject var expenses: Expenses
    
    @State private var name = ""
    @State private var type = "Personal"
    @State private var amount = ""
    @State private var types = ["Business", "Personal"]
    
    // Properties for alert
    @State private var showingAlert = false
    var body: some View {
        NavigationView {
            Form {
                // User input for name of item
                TextField("name", text: $name)
                
                // Picker for the type of item
                Picker("Type", selection: $type) {
                    ForEach(self.types, id: \.self) {
                        Text($0)
                    }
                }
                // User input for amount
                TextField("Amount", text: $amount)
                    // Only be able to type numbers
                    .keyboardType(.numberPad)
            }
            .navigationBarTitle("Add new Expense")
            .navigationBarItems(trailing:
                // Create button to save data typed in
                Button("Save") {
                // Optional binding. If it is possible to convert to int, then proceed
                if let actualAmount = Int(self.amount) {
                    // Create an item
                    let item = ExpenseItem(name: self.name, type: self.type, amount: actualAmount)
                    // Apend item to list of items
                    self.expenses.items.append(item)
                    
                    // Dismiss Add new Expense view
                    self.presentationMode.wrappedValue.dismiss()
                }
                else {
                    // We could not convert to int
                    showingAlert = true
                }
            })
        }
        .alert(isPresented: $showingAlert){
            Alert(title: Text("Warning"), message: Text("You cannot convert \(amount) into a number!"), dismissButton: .default(Text("Ok")))
        }
    }
}

struct AddView_Previews: PreviewProvider {
    static var previews: some View {
        // Pass in dummy value
        AddView(expenses: Expenses())
    }
}
