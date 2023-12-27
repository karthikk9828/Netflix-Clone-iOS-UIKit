
import Foundation
import CoreData
import UIKit

class DataPersistenceManager {
    
    enum DatabaseError: Error {
        case failedToSaveData
        case failedToGetData
        case failedToDeleteData
    }
    
    static let shared = DataPersistenceManager()
    
    func downloadContent(model: Content, completion: @escaping (Result<Void, Error>) -> Void) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        let item = ContentItem(context: context)
        item.id = Int64(model.id)
        item.originalName = model.originalName
        item.originalTitle = model.originalTitle
        item.overview = model.overview
        item.mediaType = model.mediaType
        item.posterPath = model.posterPath
        item.voteAverage = model.voteAverage
        item.voteCount = Int64(model.voteCount)
        item.releaseDate = model.releaseDate
        
        do {
            try context.save()
            completion(.success(()))
        }
        catch {
            completion(.failure(DatabaseError.failedToSaveData))
        }
    }
    
    func getDownloadedContents(completion: @escaping (Result<[ContentItem], Error>) -> Void) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        let request = ContentItem.fetchRequest()
        
        do {
            let contents = try context.fetch(request)
            completion(.success(contents))
        }
        catch {
            completion(.failure(DatabaseError.failedToGetData))
        }
    }
    
    func deleteContent(model: ContentItem, completion: @escaping (Result<Void, Error>) -> Void) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        context.delete(model) // request deletion
        
        do {
            try context.save()
            completion(.success(()))
        }
        catch {
            completion(.failure(DatabaseError.failedToDeleteData))
        }
    }
}
