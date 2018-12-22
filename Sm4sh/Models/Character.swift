//
//  Character.swift
//  Sm4sh
//
//  Created by José Javier on 12/2/18.
//  Copyright © 2018 José Javier. All rights reserved.
//

import Foundation
import RealmSwift
import Alamofire
import AlamofireObjectMapper
import ObjectMapper


class Character: Object, Mappable {
  
  @objc dynamic var objectId: String?
  @objc dynamic var name: String?
  @objc dynamic var createdAt: String?
  @objc dynamic var updatedAt: String?
  @objc dynamic var imageURL: String?
  @objc dynamic var price: String?
  @objc dynamic var popular : Bool = false
  @objc dynamic var rating: String?
  @objc dynamic var downloads: String?
  @objc dynamic var SKU: String?
  @objc dynamic var descriptionText: String = ""
  @objc dynamic var universe: String?
  @objc dynamic var kind: String?
  
  override static func primaryKey() -> String? {
    return "objectId"
  }
  
  required convenience init?(map: Map) {
    self.init()
  }
  
  func mapping(map: Map) {
    objectId        <- map["objectId"]
    name            <- map["name"]
    createdAt       <- map["createdAt"]
    updatedAt       <- map["updatedAt"]
    imageURL        <- map["imageURL"]
    price           <- map["price"]
    popular         <- map["popular"]
    rating          <- map["rating"]
    downloads       <- map["downloads"]
    SKU             <- map["SKU"]
    descriptionText <- map["description"]
    universe        <- map["universe"]
    kind            <- map["kind"]
  }
  
  // Get characters from local db
  func all(filter: String) -> Results<Character>{
    let config = Realm.Configuration(
      // Set the new schema version. This must be greater than the previously used
      // version (if you've never set a schema version before, the version is 0).
      schemaVersion: 2,
      migrationBlock: { migration, oldSchemaVersion in
        if oldSchemaVersion < 1 {
          // Apply any necessary migration logic here.
        }
    })
    Realm.Configuration.defaultConfiguration = config
    let realm = try! Realm()
    var results :Results<Character>? = nil
    if filter != "" {
      results = realm.objects(Character.self)
            .filter("universe = '\(filter)'")
            .sorted(byKeyPath: "createdAt", ascending: true)
    }else{
     results = realm.objects(Character.self)
        .sorted(byKeyPath: "createdAt", ascending: true)
    }
    return results!
  }
  
  func getUniverse() -> [String] {
    let config = Realm.Configuration(
      // Set the new schema version. This must be greater than the previously used
      // version (if you've never set a schema version before, the version is 0).
      schemaVersion: 2,
      migrationBlock: { migration, oldSchemaVersion in
        if oldSchemaVersion < 1 {
          // Apply any necessary migration logic here.
        }
    })
    Realm.Configuration.defaultConfiguration = config
    let realm = try! Realm()
    let result = realm.objects(Character.self).distinct(by: ["universe"])
    return result.map{$0.universe!}
  }
  
  // Get characters from local db
  func getPopularCharacters() -> Results<Character>{
    let config = Realm.Configuration(
      // Set the new schema version. This must be greater than the previously used
      // version (if you've never set a schema version before, the version is 0).
      schemaVersion: 2,
      migrationBlock: { migration, oldSchemaVersion in
        if oldSchemaVersion < 1 {
          // Apply any necessary migration logic here.
        }
    })
    Realm.Configuration.defaultConfiguration = config
    let realm = try! Realm()
    return realm.objects(Character.self).filter("popular = true")
  }
  
//  // Get characters from local db
//  func getNewerCharacters() -> Results<Character>{
//    let config = Realm.Configuration(
//      // Set the new schema version. This must be greater than the previously used
//      // version (if you've never set a schema version before, the version is 0).
//      schemaVersion: 2,
//      migrationBlock: { migration, oldSchemaVersion in
//        if oldSchemaVersion < 1 {
//          // Apply any necessary migration logic here.
//        }
//    })
//    Realm.Configuration.defaultConfiguration = config
//    let realm = try! Realm()
//    var results = realm.objects(Character.self)
//      .sorted(byKeyPath: "createdAt", ascending: true)
//    return results
//  }
  
  
  //Get characters from server
  static func fromServer()->Void {
    let endpoint = NetworkConnection()
    Alamofire.request(endpoint.baseURL, method: .get, parameters: nil, encoding:  JSONEncoding.default , headers: endpoint.header)
      .validate()
      .responseArray(keyPath: "results") { (response: DataResponse<[Character]>) in
        switch response.result {
        case .success(let characters):
          do {
            
            let config = Realm.Configuration(
              // Set the new schema version. This must be greater than the previously used
              // version (if you've never set a schema version before, the version is 0).
              schemaVersion: 2,
              migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 1 {
                  // Apply any necessary migration logic here.
                }
            })
            Realm.Configuration.defaultConfiguration = config
            
            let realm = try Realm()
            
            // Get our Realm file's parent directory
            let folderPath = realm.configuration.fileURL!.deletingLastPathComponent().path
            
            // Disable file protection for this directory
            try! FileManager.default.setAttributes([FileAttributeKey.protectionKey: FileProtectionType.none], ofItemAtPath: folderPath)
            
            try? realm.write {
              for character in characters {
                realm.add(character,update: true)
              }
            }
            print("something happends")
          } catch let error as NSError {
            //TODO: Handle error
            print(error.description)
          }
        case .failure(let error):
          //TODO: Handle error
          print(error)
        }
    }
  }
  
}

