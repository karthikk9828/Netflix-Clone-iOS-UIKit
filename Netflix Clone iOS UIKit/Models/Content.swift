
import Foundation

struct TrendingContentResponse : Codable {
    let results: [Content]
}

struct Content : Codable {
    let id: Int
    let mediaType: String?
    let originalName: String?
    let originalTitle: String?
    let posterPath: String?
    let overview: String?
    let voteCount: Int
    let voteAverage: Double
    let releaseData: String?
}
