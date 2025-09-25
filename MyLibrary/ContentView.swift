import SwiftUI

// MARK: - Model
struct Book: Identifiable, Equatable {
    let id: UUID = UUID()
    var title: String
    var author: String
    var summary: String
}

// MARK: - Sample Data
let sampleBooks: [Book] = [
    Book(title: "1984", author: "George Orwell", summary: "A dystopian classic about surveillance and control." ),
    Book(title: "The Lord of the Rings", author: "J.R.R. Tolkien", summary: "Frodo's journey to destroy the One ring."),
    Book(title: "Dune", author: "Frank Herbert", summary: "Politics, religion, and ecology on a desert planet.")
]

//MARK: - ContentView (main list)
struct ContentView: View {
    @State private var books: [Book] = sampleBooks
    @State private var showingAdd = false
    @State private var searchText: String = ""

    // filtered list based on search text
    private var filteredBooks: [Book] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return books
        } else {
            return books.filter { book in
                book.title.localizedCaseInsensitiveContains(searchText) ||
                book.author.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredBooks) { book in
                    NavigationLink(destination: BookDetailView(book: book)) {
                        VStack(alignment: .leading) {
                            Text(book.title)
                                .font(.headline)
                            Text(book.author)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 6)
                    }
                }
                .onDelete { indexSet in
                    // when deleting we must map the indexSet from filteredBooks to books
                    // simplest: remove from the main array using the indices of filteredBooks
                    let toRemove = indexSet.compactMap { idx -> UUID? in
                        guard idx < filteredBooks.count else { return nil }
                        return filteredBooks[idx].id
                    }
                    books.removeAll { book in toRemove.contains(book.id) }
                }
            } // end List
            .listStyle(.insetGrouped)
            .navigationTitle("MyLibrary")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAdd = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddBookView { newBook in
                    books.append(newBook)
                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic))
        } // end NavigationStack
    } // end body
} // end ContentView
//MARK: - AddBookView (sheet with form)
struct AddBookView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var author: String = ""
    @State private var summary: String = ""

    // ⚠️ make closure escaping so it's safe to store/call
    var onSave: (Book) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Title")) {
                    TextField("Enter title", text: $title)
                }

                Section(header: Text("Author")) {
                    TextField("Enter author", text: $author)
                }

                Section(header: Text("Summary")) {
                    TextEditor(text: $summary)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Add Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let newBook = Book(
                            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                            author: author.trimmingCharacters(in: .whitespacesAndNewlines),
                            summary: summary.trimmingCharacters(in: .whitespacesAndNewlines)
                        )
                        onSave(newBook)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
// MARK: - Simple book detail
struct BookDetailView: View {
    let book: Book
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(book.title)
                .font(.title)
                .bold()
            
            Text("By \(book.author)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        }
    }

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
