//
//  Logic2.swift
//  Coom2
//
//  Created by Christian Norton on 5/15/24.
//

import Foundation
import AVFoundation

struct Creator: Codable, Identifiable {
    var id: String?
    var service: String?
    var indexed: String?
    var updated: Int?
    var name: String? // Make name optional to handle missing keys
    
    // Custom decoding to handle type mismatches
    enum CodingKeys: String, CodingKey {
        case id, service, indexed, updated, name
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        service = try container.decode(String.self, forKey: .service)
        updated = try container.decode(Int.self, forKey: .updated)
        
        // Handle name as optional
        name = try? container.decode(String.self, forKey: .name)
        
        // Handle indexed field that can be either String or Int
        if let indexedInt = try? container.decode(Int.self, forKey: .indexed) {
            indexed = String(indexedInt)
        } else if let indexedString = try? container.decode(String.self, forKey: .indexed) {
            indexed = indexedString
        } else {
            throw DecodingError.typeMismatch(String.self, DecodingError.Context(codingPath: [CodingKeys.indexed], debugDescription: "Expected String or Int for indexed field"))
        }
    }
}

struct Post: Codable, Identifiable {
    var id: String?
    var user: String?
    var service: String?
    var title: String?
    var content: String?
    var embed: [String: String]?
    var sharedFile: String? = ""
    var added: String?
    var published: String?
    var edited: String?
    var file: FileDetails?
    var attachments: [Attachment]?
    
    struct FileDetails: Codable {
        let name: String?
        let path: String?
    }
    
    struct Attachment: Codable, Identifiable {
            let id = UUID()
            let name: String
            let path: String
        }
}

struct Attachment: Identifiable, Codable {
    let id = UUID()  // Automatically generates a unique ID
    let name: String?
    let path: String?
    
    private enum CodingKeys: String, CodingKey {
        case name
        case path
    }
}

struct Comment: Codable, Identifiable {
    let id: String
    let parentId: String?
    let commenter: String
    let content: String
    let published: String
    
    // Custom coding keys to handle different key names
    enum CodingKeys: String, CodingKey {
        case id, parentId = "parent_id", commenter, content, published
    }
}

struct PostDetail: Codable, Identifiable {
    let id: String
    let title: String
    let content: String?
    let videoURL: String?
    
    enum CodingKeys: String, CodingKey {
        case id, title, content, videoURL = "video_url"
    }
}

struct ApiResponse<T: Codable>: Codable {
    let data: [T]
}

extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

class ApiService {
    static let shared = ApiService()
    
    private let baseURL = "https://coomer.su/api/v1"
    
    private init() {}
    
    func fetchCreators(completion: @escaping (Result<[Creator], Error>) -> Void) {
        let url = URL(string: "\(baseURL)/creators.txt")!
        fetch(url: url, completion: completion)
    }
    
    func fetchRecentPosts(completion: @escaping (Result<[Post], Error>) -> Void) {
        let url = URL(string: "\(baseURL)/posts")!
        fetch(url: url, completion: completion)
    }
    
    func fetchCreatorPosts(service: String, creatorID: String, completion: @escaping (Result<[Post], Error>) -> Void) {
          let url = URL(string: "\(baseURL)/\(service)/user/\(creatorID)")!
          fetch(url: url, completion: completion)
      }
    
    
    private func fetch<T: Codable>(url: URL, completion: @escaping (Result<[T], Error>) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data"])))
                return
            }
            
            // Print the raw JSON response for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw JSON response: \(jsonString)")
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode([T].self, from: data)
                completion(.success(response))
            } catch {
                print("Decoding error: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
}

extension DateFormatter {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
}

extension AVAsset {
    func videoSize() async throws -> CGSize? {
        guard let track = try await loadTracks(withMediaType: .video).first else { return nil }
        let size = try await track.load(.naturalSize)
        return size
    }
}
