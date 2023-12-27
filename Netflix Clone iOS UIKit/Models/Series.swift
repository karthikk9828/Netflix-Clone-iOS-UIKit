
import Foundation

struct TrendingSeriesResponse : Codable {
    let results: [Series]
}

struct Series : Codable {
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
