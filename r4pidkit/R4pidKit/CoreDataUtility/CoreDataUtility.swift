//
//  CoreDataUtility.swift
//  R4pidKit
//
//  Created by Justine Angelo Rangel on 19/06/2018.
//  Copyright © 2018 R4pid Inc. All rights reserved.
//

import Foundation
import CoreData

public let CoreDataUtil = CoreDataUtility.shared

public class CoreDataUtility {
  public static let shared = CoreDataUtility()
  
  public enum MergePolicy {
    case error
    case mergeByPropertyStoreTrump
    case mergeByPropertyObjectTrump
    case overwrite
    case rollback
    
    public var policy: NSMergePolicy {
      switch self {
      case .error:
        return .error
      case .mergeByPropertyStoreTrump:
        return .mergeByPropertyStoreTrump
      case .mergeByPropertyObjectTrump:
        return .mergeByPropertyObjectTrump
      case .overwrite:
        return  .overwrite
      case .rollback:
        return .rollback
      }
    }
  }

  private init() {}

  public var dbName: String = "DatabaseName"
  public var showLogs: Bool = false
  public var mergePolicy: MergePolicy = .mergeByPropertyObjectTrump

  private lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: self.dbName)
    container.loadPersistentStores(completionHandler: { (_, error) in
      if let error = error as NSError? {
        fatalError(concatenate("Unresolved error ", error, ", ", error.userInfo))
      }
    })
    container.viewContext.mergePolicy = mergePolicy.policy
    container.viewContext.automaticallyMergesChangesFromParent = true
    return container
  }()

  //Used for Reading context (as much as possible use this for viewing/fetching)
  public private(set) lazy var mainMOC: NSManagedObjectContext = {
    return self.persistentContainer.viewContext
  }()

  /// Save main view context if theres any
  public func save(_ completion: ((_ isSucess: Bool) -> Void)? = nil) {
    mainMOC.performAndWait {
      if mainMOC.hasChanges {
        do {
          try mainMOC.save()
          completion?(true)
        } catch {
          completion?(false)
          CoreDataUtility.debugLog("Error saving main MOC: ", error.localizedDescription)
        }
      } else {
        completion?(false)
      }
    }
  }

  /// Perform backgroud task and save
  ///
  /// - Parameters:
  ///   - task: contains task to perform on background
  ///   - completion: contains task to perform after the background task in the main thread
  public func performBackgroundTask(_ task: @escaping (_ backgroundMOC: NSManagedObjectContext) -> Void, completion: ((_ isSuccess: Bool) -> Void)? = nil) {
    persistentContainer.performBackgroundTask { (backgroundMOC) in
      backgroundMOC.mergePolicy =  CoreDataUtil.mergePolicy.policy
      task(backgroundMOC)
      if backgroundMOC.hasChanges {
        do {
          try backgroundMOC.save()
          self.save({ (isSuccess) in
            completion?(isSuccess)
          })
        } catch {
          DispatchQueue.main.async {
            completion?(false)
          }
          CoreDataUtility.debugLog("Error saving background MOC: ", error.localizedDescription)
        }
      } else {
        DispatchQueue.main.async {
          completion?(false)
        }
      }
    }
  }

  fileprivate static func debugLog(_ items: Any...) {
    if CoreDataUtil.showLogs {
      print("CoreDataUtility: ")
      for (i, item) in items.enumerated() {
        print(item, terminator: (i + 1) == items.count ? "\n" : " ")
      }
    }
  }
}

extension NSManagedObjectContext {
  public static var main: NSManagedObjectContext {
    return CoreDataUtil.mainMOC
  }
  
  /// When using does not fire fetch results controller delegate but should reload
  public func executeDeleteAndMergeChanges(_ request: NSBatchDeleteRequest) throws {
    request.resultType = .resultTypeObjectIDs
    let result = try execute(request) as? NSBatchDeleteResult
    guard let objectIDArray = result?.result as? [NSManagedObjectID] else { return }
    let changes: [AnyHashable: Any] = [NSDeletedObjectsKey : objectIDArray]
    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self])
  }
}

//CORE DATA RECIPE FOR UPDATING FETCH REQUEST
public struct CoreDataRecipe {
  public enum Sort {
    case id(isAscending: Bool)
    case sortIndex(isAscending: Bool)
    case dateCreated(isAscending: Bool)
    case custom(key: String, isAscending: Bool)
  }

  public enum Range {
    case range(offset: Int, limit: Int) //offset start index and limit sequence after
    case first //suggested to use first on getting single data
  }

  public enum Predicate {
    case compoundAnd(predicates: [Predicate])
    case compoundOr(predicates: [Predicate])
    case isEqual(key: String, value: Any?)
    case isEqualIn(key: String, values: [Any])
    case notEqual(key: String, value: Any?)
    case notEqualIn(key: String, values: [Any])
    case contains(key: String, value: String)
    case notContains(key: String, value: String)
    case custom(predicate: NSPredicate)

    public var rawValue: NSPredicate {
      switch self {
      case .compoundAnd(let predicates):
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates.map({ $0.rawValue }))
      case .compoundOr(let predicates):
        return NSCompoundPredicate(orPredicateWithSubpredicates: predicates.map({ $0.rawValue }))
      case .isEqual(let key, let value)://Put here adding support to other value types
        if let value = value as? String {
          return NSPredicate(format: "%K = %@", key, value)
        } else if let value = value as? NSNumber {
          return NSPredicate(format: "%K = %@", key, value)
        } else {
          return NSPredicate(format: "%K = nil", key)
        }
      case .isEqualIn(let key, let values):
        return NSPredicate(format: "%K IN %@", key, values.map { (value) -> Any? in
          if let value = value as? String {
            return value
          } else if let value = value as? NSNumber {
            return value
          } else {
            return nil
          }
        }.compactMap({ $0 }))
      case .notEqual(let key, let value):
        if let value = value as? String {
          return NSPredicate(format: "%K != %@", key, value)
        } else if let value = value as? NSNumber {
          return NSPredicate(format: "%K != %@", key, value)
        } else {
          return NSPredicate(format: "%K != nil", key)
        }
      case .notEqualIn(let key, let values):
        return NSPredicate(format: "NOT (%K IN %@)", key, values.map { (value) -> Any? in
          if let value = value as? String {
            return value
          } else if let value = value as? NSNumber {
            return value
          } else {
            return nil
          }
          }.compactMap({ $0 }))
      case .contains(let key, let value):
        return NSPredicate(format: "%K contains[cd] %@", key, value)
      case .notContains(let key, let value):
        return NSPredicate(format: "NOT (%K contains[cd] %@)", key, value)
      case .custom(let predicate):
        return predicate
      }
    }
  }
  
  public struct Distinct {
    public var properties: [String]
    public var resultType: NSFetchRequestResultType = .managedObjectResultType
    
    public init(properties: [String], resultType: NSFetchRequestResultType = .managedObjectResultType) {
      self.properties = properties
      self.resultType = resultType
    }
  }
  
  public init() {
  }
  
  public init(sorts: [Sort], range: Range?, predicate: NSPredicate?, distinct: Distinct?) {
    self.sorts = sorts
    self.range = range
    self.predicate = predicate
    self.distinct = distinct
  }

  public var sorts: [Sort] = []
  public var range: Range?
  public var predicate: NSPredicate?
  public var distinct: Distinct?
}

//CONVERT CORE DATA RECIPE SORT TO NSSORTDESCRIPTOR
extension NSSortDescriptor {
  public convenience init(sortRecipe: CoreDataRecipe.Sort) {
    switch sortRecipe {
    case .id(let isAscending):
      self.init(key: "id", ascending: isAscending)
    case .sortIndex(let isAscending):
      self.init(key: "sortIndex", ascending: isAscending)
    case .dateCreated(let isAscending):
      self.init(key: "dateCreated", ascending: isAscending)
    case .custom(let key, let isAscending):
      self.init(key: key, ascending: isAscending)
    }
  }
}

public protocol ManagedObjectConfigurable: ReuseIdentifier {
}

extension NSManagedObject: ManagedObjectConfigurable {
  public func delete() {
    guard let moc = managedObjectContext else { return }
    moc.delete(self)
  }
  
  public func insert(inMOC: NSManagedObjectContext) {
    inMOC.insert(self)
  }
}

extension ManagedObjectConfigurable where Self: NSManagedObject {
  ///create a generic fetch request
  public static func createFetchRequest<T>() -> NSFetchRequest<T> where T: NSFetchRequestResult {
    return NSFetchRequest<T>(entityName: identifier)
  }
}

public protocol CoreDataUtilityConfigurable {
}

extension CoreDataUtility: CoreDataUtilityConfigurable {
}

extension CoreDataUtilityConfigurable {
  ///used for create or update
  public func createEntity<T: ManagedObjectConfigurable>(_ entity: T.Type, fromEntity: T? = nil, inMOC: NSManagedObjectContext = .main) -> T {
    if let fromEntity = fromEntity { return fromEntity }
    return NSEntityDescription.insertNewObject(forEntityName: entity.identifier, into: inMOC) as! T
  }

  ///delete entity
  public func deleteEntity(_ entity: NSManagedObject, inMOC: NSManagedObjectContext) {
    inMOC.delete(entity)
  }

  ///delete supplied entities
  public func deleteEntities(_ entities: [NSManagedObject], inMOC: NSManagedObjectContext) {
    for entity in entities {
      deleteEntity(entity, inMOC: inMOC)
    }
  }

  ///truncate entity
  public func truncateEntity<T: NSManagedObject>(_ entity: T.Type, inMOC: NSManagedObjectContext) {
    performBatchDelete(T.self, inMOC: inMOC)
//    inMOC.reset() uncomment if batch  delete does not work on truncate method
  }

  ///get object
  public func get<T: NSManagedObject>(_ entity: T.Type, predicate: CoreDataRecipe.Predicate? = nil, inMOC: NSManagedObjectContext = .main) -> T? {
    var coreDataRecipe = CoreDataRecipe()
    coreDataRecipe.range = .first
    coreDataRecipe.predicate = predicate?.rawValue
    let fetchRequest: NSFetchRequest<T> = T.createFetchRequest()

    return fetchObject(for: fetchRequest, recipe: coreDataRecipe, inMOC: inMOC)
  }

  ///list objects
  public func list<T: NSManagedObject>(_ entity: T.Type, predicate: CoreDataRecipe.Predicate? = nil, range: CoreDataRecipe.Range? = nil, sorts: [CoreDataRecipe.Sort]? = nil, inMOC: NSManagedObjectContext = .main) -> [T] {
    var coreDataRecipe = CoreDataRecipe()
    coreDataRecipe.range = range
    coreDataRecipe.predicate = predicate?.rawValue
    if let sorts = sorts {
      coreDataRecipe.sorts = sorts
    }
    let fetchRequest: NSFetchRequest<T> = T.createFetchRequest()

    return fetchObjects(for: fetchRequest, recipe: coreDataRecipe, inMOC: inMOC)
  }

  ///list any objects will be used on special cases e.g with distinct properties
  public func listObjects<T: NSManagedObject>(_ entity: T.Type, recipe: CoreDataRecipe, inMOC: NSManagedObjectContext = .main) -> [Any] {
    let fetchRequest: NSFetchRequest<T> = T.createFetchRequest()
    return fetchAnyObjects(for: fetchRequest as! NSFetchRequest<NSFetchRequestResult>, recipe: recipe, inMOC: inMOC)
  }

  ///count objects
  public func count<T: NSManagedObject>(_ entity: T.Type, predicate: CoreDataRecipe.Predicate? = nil, range: CoreDataRecipe.Range? = nil, inMOC: NSManagedObjectContext = .main) -> Int {
    var coreDataRecipe = CoreDataRecipe()
    coreDataRecipe.range = range
    coreDataRecipe.predicate = predicate?.rawValue
    let fetchRequest: NSFetchRequest<T> = T.createFetchRequest()

    return fetchCount(for: fetchRequest, recipe: coreDataRecipe, inMOC: inMOC)
  }

  ///fetch objects using fetch request
  public func fetchObjects<T>(for fetchRequest: NSFetchRequest<T>, recipe: CoreDataRecipe, inMOC: NSManagedObjectContext) -> [T] {
    updateFetchRequest(fetchRequest, recipe: recipe)
    var results: [T] = []
    do {
      results = try inMOC.fetch(fetchRequest)
    } catch {
      CoreDataUtility.debugLog(error.localizedDescription)
    }
    return results
  }

  ///fetch object using fetch request
  public func fetchObject<T>(for fetchRequest: NSFetchRequest<T>, recipe: CoreDataRecipe, inMOC: NSManagedObjectContext) -> T? {
    updateFetchRequest(fetchRequest, recipe: recipe)
    var result: T?
    do {
      result = try inMOC.fetch(fetchRequest).first
    } catch {
      CoreDataUtility.debugLog(error.localizedDescription)
    }
    return result
  }

  ///fetch count using fetch request
  public func fetchCount<T>(for fetchRequest: NSFetchRequest<T>, recipe: CoreDataRecipe, inMOC: NSManagedObjectContext) -> Int {
    updateFetchRequest(fetchRequest, recipe: recipe)
    fetchRequest.resultType = .countResultType
    var resultCount = 0
    do {
      resultCount = try inMOC.count(for: fetchRequest)
    } catch {
      CoreDataUtility.debugLog(error.localizedDescription)
    }
    return resultCount
  }

  ///fetch any objects
  public func fetchAnyObjects(for fetchRequest: NSFetchRequest<NSFetchRequestResult>, recipe: CoreDataRecipe, inMOC: NSManagedObjectContext) -> [Any] {
    updateFetchRequest(fetchRequest, recipe: recipe)
    var results: [Any] = []
    do {
      results = try inMOC.fetch(fetchRequest)
    } catch {
      CoreDataUtility.debugLog(error.localizedDescription)
    }
    return results
  }

  public func updateFetchRequest<T>(_ fetchRequest: NSFetchRequest<T>, recipe: CoreDataRecipe) {
    fetchRequest.predicate = recipe.predicate
    if let recipeRange = recipe.range {
      switch recipeRange {
      case .range(let offset, let limit):
        fetchRequest.fetchOffset = offset
        fetchRequest.fetchLimit = limit
      case .first:
        fetchRequest.fetchLimit = 1
      }
    }

    if let distinct = recipe.distinct {
      fetchRequest.propertiesToFetch = distinct.properties
      fetchRequest.returnsDistinctResults = true
      fetchRequest.resultType = distinct.resultType
    }

    fetchRequest.sortDescriptors = recipe.sorts.map({ NSSortDescriptor(sortRecipe: $0) })
  }
}

extension CoreDataUtilityConfigurable {
  //doesn't support keys with customer.id as sample
  public func performBatchUpdate<T: NSManagedObject>(_ entity: T.Type, predicate: CoreDataRecipe.Predicate, updateDict: [String: Any], inMOC: NSManagedObjectContext = .main) {
    let batchUpdateRequest = NSBatchUpdateRequest(entityName: entity.identifier)
    batchUpdateRequest.predicate = predicate.rawValue
    batchUpdateRequest.propertiesToUpdate = updateDict
    do {
      try inMOC.execute(batchUpdateRequest)
    } catch {
      CoreDataUtility.debugLog(error.localizedDescription)
    }
  }
  
  public func performBatchDelete<T: NSManagedObject>(_ entity: T.Type, predicate: CoreDataRecipe.Predicate? = nil, inMOC: NSManagedObjectContext = .main) {
    let fetchRequest: NSFetchRequest<T> = T.createFetchRequest()
    fetchRequest.predicate = predicate?.rawValue
    let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
    do {
      try inMOC.executeDeleteAndMergeChanges(batchDeleteRequest)
    } catch {
      CoreDataUtility.debugLog(error.localizedDescription)
    }
  }
}

public protocol FetchResultsControllerHandlerDelegate: class {
  func fetchResultsWillUpdateContent(hander: Any)
  func fetchResultsDidUpdateContent(handler: Any)
}

public class FetchResultsControllerHandler<T: NSManagedObject>: NSObject, NSFetchedResultsControllerDelegate {
  public enum HandlerType {
    case tableView(_ tableView: UITableView)
    case collectionView(_ collectionView: UICollectionView)
  }
  
  private struct CollectionViewOperations {
    var insertSections: [Int] = []
    var deleteSections: [Int] = []
    var insertPaths: [IndexPath] = []
    var reloadPaths: [IndexPath] = []
    var deletePaths:  [IndexPath] = []
    
    mutating func reset() {
      insertSections.removeAll()
      deleteSections.removeAll()
      insertPaths.removeAll()
      reloadPaths.removeAll()
      deletePaths.removeAll()
    }
    
    func start(collectionView: UICollectionView) {
      if !insertSections.isEmpty {
        collectionView.insertSections(IndexSet(insertSections))
      }
      if !deleteSections.isEmpty {
        collectionView.deleteSections(IndexSet(deleteSections))
      }
      collectionView.insertItems(at: insertPaths)
      collectionView.reloadItems(at: reloadPaths)
      collectionView.deleteItems(at: deletePaths)
    }
  }
  
  private let fetchResultsController: NSFetchedResultsController<T>
  private let type: HandlerType
  private var collectionViewOperations = CollectionViewOperations()
  
  public weak var delegate: FetchResultsControllerHandlerDelegate?
  
  public init(type: HandlerType, sectionKey: String? = nil) {
    let fetchRequest: NSFetchRequest<T> = T.createFetchRequest()
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
    fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: .main, sectionNameKeyPath: sectionKey, cacheName: nil)
    self.type = type
    super.init()
    fetchResultsController.delegate = self
  }
  
  public func reload(recipe: CoreDataRecipe) {
    do {
      CoreDataUtil.updateFetchRequest(fetchResultsController.fetchRequest, recipe: recipe)
      try fetchResultsController.performFetch()
    } catch {
      r4pidLog(error.localizedDescription)
    }
    switch type {
    case .tableView(let tableView):
      tableView.reloadData()
    case .collectionView(let collectionView):
      collectionView.reloadData()
    }
  }
  
  public var sections: [NSFetchedResultsSectionInfo]? {
    return fetchResultsController.sections
  }
  
  public func numberOfObjectsInSection(_ section: Int) -> Int {
    guard let sections = fetchResultsController.sections, sections.count > section else { return 0 }
    return sections[section].numberOfObjects
  }
  
  public func object(at indexPath: IndexPath) -> T {
    return fetchResultsController.object(at: indexPath)
  }
  
  public func indexPath(forObject: T) -> IndexPath? {
    return fetchResultsController.indexPath(forObject: forObject)
  }
  
  public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    switch type {
    case .tableView(let tableView):
      delegate?.fetchResultsWillUpdateContent(hander: self)
      tableView.beginUpdates()
    case .collectionView:
      delegate?.fetchResultsWillUpdateContent(hander: self)
      collectionViewOperations.reset()
    }
  }
  
  public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    switch type {
    case .tableView(let tableView):
      tableView.endUpdates()
      delegate?.fetchResultsDidUpdateContent(handler: self)
    case .collectionView(let collectionView):
      collectionView.performBatchUpdates({
        collectionViewOperations.start(collectionView: collectionView)
      }, completion: { (_) in
        self.delegate?.fetchResultsDidUpdateContent(handler: self)
      })
    }
  }
  
  
  public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
    switch type {
    case .insert:
      switch self.type {
      case .tableView(let tableView):
        tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
      case .collectionView:
        collectionViewOperations.insertSections.append(sectionIndex)
      }
    case .delete:
      switch self.type {
      case .tableView(let tableView):
        tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
      case .collectionView:
        collectionViewOperations.deleteSections.append(sectionIndex)
      }
    case .update: break
    case .move: break
    @unknown default:
      r4pidLog("FetchResultsControllerHandler ", #function)
    }
  }
  
  public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    switch type {
    case .insert:
      guard let newIndexPath = newIndexPath else { return }
      switch self.type {
      case .tableView(let tableView):
        tableView.insertRows(at: [newIndexPath], with: .fade)
      case .collectionView:
        collectionViewOperations.insertPaths.append(newIndexPath)
      }
    case .delete:
      guard let indexPath = indexPath else { return }
      switch self.type {
      case .tableView(let tableView):
        tableView.deleteRows(at: [indexPath], with: .fade)
      case .collectionView:
        collectionViewOperations.deletePaths.append(indexPath)
      }
    case .update:
      guard let indexPath = indexPath else { return }
      switch self.type {
      case .tableView(let tableView):
        tableView.reloadRows(at: [indexPath], with: .fade)
      case .collectionView:
        collectionViewOperations.reloadPaths.append(indexPath)
      }
    case .move:
      guard let indexPath = indexPath, let newIndexPath = newIndexPath else { return }
      switch self.type {
      case .tableView(let tableView):
        tableView.deleteRows(at: [indexPath], with: .fade)
        tableView.insertRows(at: [newIndexPath], with: .fade)
      case .collectionView:
        collectionViewOperations.deletePaths.append(indexPath)
        collectionViewOperations.insertPaths.append(newIndexPath)
      }
    @unknown default:
      r4pidLog("FetchResultsControllerHandler ", #function)
    }
  }
}

//Sample code
//CoreDataUtil.performBackgroundTask({ (moc) in //do heavy lifting here
//  CoreDataUtil.truncateEntity(Product.self, inMOC: moc)
//  let yugiProduct = CoreDataUtil.createEntity(Product.self, inMOC: moc)
//  yugiProduct.name = "Yugioh"
//  yugiProduct.id = "1"
//  let kaibaProduct = CoreDataUtil.createEntity(Product.self, inMOC: moc)
//  kaibaProduct.name = "Kaiba"
//  kaibaProduct.id = "53"
//  let kaibaProduct2 = CoreDataUtil.createEntity(Product.self, inMOC: moc)
//  kaibaProduct2.name = "Kaiba"
//  kaibaProduct2.id = "5453121"
//  let kaibaProduct3 = CoreDataUtil.createEntity(Product.self, inMOC: moc)
//  kaibaProduct3.name = "Kaiba"
//  kaibaProduct3.id = "5431253"
//}) { (_) in //do main thread here
//
//  let product = CoreDataUtil.get(Product.self, predicate: .isEqual(key: "id", value: "53"), inMOC: .main)
//  print("product id: ", product!.id!)
//  print("product name: ", product!.name!)
//
//  //equal with range
//  let list = CoreDataUtil.list(Product.self, predicate: .isEqual(key: "name", value: "Kaiba"), range: .range(offset: 0, limit: 10), inMOC: .main)
//  for (i,p) in list.enumerated() {
//    print(i, " product id: ", p.id!, " AND product name: ", p.name!)
//  }
//
//  //compound
//  let list2 = CoreDataUtil.list(Product.self, predicate: .compoundAnd(predicates: [.isEqual(key: "name", value: "Kaiba"), .isEqual(key: "id", value: "53")]), range: .range(offset: 0, limit: 10), inMOC: .main)
//  for (i,p) in list2.enumerated() {
//    print(i, " product id: ", p.id!, " AND product name: ", p.name!)
//  }
//
//  //contains with range
//  let list3 = CoreDataUtil.list(Product.self, predicate: .contains(key: "id", value: "312"), range: .range(offset: 0, limit: 10), inMOC: .main)
//  for (i,p) in list3.enumerated() {
//    print(i, " product id: ", p.id!, " AND product name: ", p.name!)
//  }
//
//  //contains contains with name and sorts with id
//  let list4 = CoreDataUtil.list(Product.self, predicate: .contains(key: "name", value: "i"), range: .range(offset: 0, limit: 10), sorts: [.id(isAscending: true)], inMOC: .main)
//  for (i,p) in list4.enumerated() {
//    print(i, " product id: ", p.id!, " AND product name: ", p.name!)
//  }
//
//  //count product that contains name with i
//  let count = CoreDataUtil.count(Product.self, predicate: .contains(key: "name", value: "i"), inMOC: .main)
//  print("product count: ", count)
//}
