import Foundation

struct URLMetadata {
    let url: URL
    let title: String
    let thumbnailImageURL: URL?
    let screenshotData: Data?
    let createdAt: Date
    let updatedAt: Date
    let deletedAt: Date?
}
