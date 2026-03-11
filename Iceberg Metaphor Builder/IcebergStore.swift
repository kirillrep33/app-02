import Foundation
import SwiftUI


enum IcebergStatus: String, Codable {
    case inProgress
    case solved
    case notSolved
}


struct IcebergItem: Identifiable, Equatable, Codable {
    let id: UUID
    var title: String
    var aboveItems: [String]
    var belowItems: [String]
    var status: IcebergStatus
    var firstAnswer: String
    var secondAnswer: String
    var thirdAnswer: String
    var deadline: Date?
    var solutionNote: String?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        aboveItems: [String],
        belowItems: [String],
        status: IcebergStatus = .inProgress,
        firstAnswer: String = "",
        secondAnswer: String = "",
        thirdAnswer: String = "",
        deadline: Date? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.aboveItems = aboveItems
        self.belowItems = belowItems
        self.status = status
        self.firstAnswer = firstAnswer
        self.secondAnswer = secondAnswer
        self.thirdAnswer = thirdAnswer
        self.deadline = deadline
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}


final class IcebergStore: ObservableObject {
    @Published var items: [IcebergItem] = [] {
        didSet {
            saveItems()
        }
    }
    
    private let itemsKey = "IcebergItems"
    
    init() {
        loadItems()
    }
    
    private func saveItems() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: itemsKey)
        }
    }
    
    private func loadItems() {
        if let data = UserDefaults.standard.data(forKey: itemsKey),
           let decoded = try? JSONDecoder().decode([IcebergItem].self, from: data) {
            items = decoded
        }
    }

    func add(
        title: String,
        aboveItems: [String],
        belowItems: [String],
        firstAnswer: String,
        secondAnswer: String,
        thirdAnswer: String,
        deadline: Date?
    ) {
        let trimmedAbove = aboveItems.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        let trimmedBelow = belowItems.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        let t1 = firstAnswer.trimmingCharacters(in: .whitespacesAndNewlines)
        let t2 = secondAnswer.trimmingCharacters(in: .whitespacesAndNewlines)
        let t3 = thirdAnswer.trimmingCharacters(in: .whitespacesAndNewlines)
        let now = Date()

        let item = IcebergItem(
            title: title,
            aboveItems: trimmedAbove,
            belowItems: trimmedBelow,
            status: .inProgress,
            firstAnswer: t1,
            secondAnswer: t2,
            thirdAnswer: t3,
            deadline: deadline,
            createdAt: now,
            updatedAt: now
        )
        items.append(item)
    }

    func remove(_ item: IcebergItem) {
        items.removeAll { $0.id == item.id }
        saveItems()
    }

    func updateStatus(for item: IcebergItem, to status: IcebergStatus) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx].status = status
        items[idx].updatedAt = Date()
        saveItems()
    }

    func updateSolutionNote(for item: IcebergItem, note: String?) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx].solutionNote = note
        items[idx].updatedAt = Date()
        saveItems()
    }

    func update(
        item: IcebergItem,
        title: String,
        aboveItems: [String],
        belowItems: [String],
        firstAnswer: String,
        secondAnswer: String,
        thirdAnswer: String,
        deadline: Date?
    ) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }

        let trimmedAbove = aboveItems.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        let trimmedBelow = belowItems.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        let t1 = firstAnswer.trimmingCharacters(in: .whitespacesAndNewlines)
        let t2 = secondAnswer.trimmingCharacters(in: .whitespacesAndNewlines)
        let t3 = thirdAnswer.trimmingCharacters(in: .whitespacesAndNewlines)

        items[idx].title = title
        items[idx].aboveItems = trimmedAbove
        items[idx].belowItems = trimmedBelow
        items[idx].firstAnswer = t1
        items[idx].secondAnswer = t2
        items[idx].thirdAnswer = t3
        items[idx].deadline = deadline
        items[idx].updatedAt = Date()

        saveItems()
    }
}

