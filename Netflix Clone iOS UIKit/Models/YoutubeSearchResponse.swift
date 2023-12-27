
import Foundation

struct YoutubeSearchResponse: Codable {
    let items: [VideoElelment]
}

struct VideoElelment: Codable {
    let id: VideoElelmentId
}

struct VideoElelmentId: Codable {
    let kind: String
    let videoId: String
}
