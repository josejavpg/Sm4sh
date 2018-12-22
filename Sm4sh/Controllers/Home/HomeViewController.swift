//
//  ViewController.swift
//  Sm4sh
//
//  Created by José Javier on 12/1/18.
//  Copyright © 2018 José Javier. All rights reserved.
//

import UIKit
import RealmSwift

class HomeViewController: UIViewController {

  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var newCollectionView: UICollectionView!
  @IBOutlet weak var popularCollectionView: UICollectionView!
  @IBOutlet weak var filterCollectionView: UICollectionView!
  @IBOutlet weak var newLabel: UILabel!
  @IBOutlet weak var popularLabel: UILabel!
  @IBOutlet weak var allLabel: UILabel!
  
  var allCharacters : Results<Character>?
  var newCharacters : [Character] = [Character]()
  var popularCharacters : Results<Character>?
  
  var filterString = ""
  
  var gamesList : [String] = []
  let optionalImage = "https://vignette.wikia.nocookie.net/videojuego/images/7/70/Super_Smash_Bros_Logo.png/revision/latest?cb=20100417215527"
  
  fileprivate func loadData(filter: Bool) {
    
  
    Character.fromServer()
    
    DispatchQueue.main.async {
      let data = Character()
      self.allCharacters = data.all(filter: self.filterString)
      
      self.popularCharacters = data.getPopularCharacters()
      var counter = 0
      if self.newCharacters.count == 0{
        for character in self.allCharacters!{
          if counter < 5{
            self.newCharacters.append(character)
            counter += 1
          }
        }
      }
      
      if self.gamesList.count == 0{
        self.gamesList = data.getUniverse()
        self.gamesList.insert("All", at: 0)
      }
      
      self.collectionView.reloadData()
      self.newCollectionView.reloadData()
      self.popularCollectionView.reloadData()
      
      if filter{
        self.filterCollectionView.reloadData()
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //setup custom cells
    let nibCell = UINib(nibName: "CharacterCell", bundle: nil)
    collectionView.register(nibCell, forCellWithReuseIdentifier: "CharacterCell")
    
    let nibSmallCell = UINib(nibName: "CharacterSmallCell", bundle: nil)
    newCollectionView.register(nibSmallCell, forCellWithReuseIdentifier: "CharacterSmallCell")
    popularCollectionView.register(nibSmallCell, forCellWithReuseIdentifier: "CharacterSmallCell")
    
    loadData(filter: true)
    self.filterCollectionView.reloadData()
  }
  
  @objc func buttonClicked(_ sender : UIButton) {
    //self.loadData(filter: sender.titleLabel?.text ?? "")
    if sender.tag > 0{
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
      
      self.allCharacters = realm.objects(Character.self)
        .filter("universe = '\(sender.titleLabel!.text ?? "")'")
      self.popularCharacters = realm.objects(Character.self).filter("popular = true && universe = '\(sender.titleLabel!.text ?? "")'")
      
      self.collectionView.reloadData()
      self.newCollectionView.reloadData()
      self.popularCollectionView.reloadData()
    }else{
      self.loadData(filter: false)
    }
      sender.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
      sender.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
  
  }

}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource{
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    switch collectionView {
    case self.collectionView:
      self.allLabel.text = "All (\(allCharacters?.count ?? 0))"
      return allCharacters?.count ?? 0
    case self.newCollectionView:
      self.newLabel.text = "New (\(newCharacters.count ))"
      return newCharacters.count
    case self.popularCollectionView:
      self.popularLabel.text = "Popular (\(popularCharacters?.count ?? 0))"
      return popularCharacters?.count ?? 0
    case self.filterCollectionView:
      return self.gamesList.count
    default:
      return 0
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
  
    if collectionView == self.collectionView{
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CharacterCell", for: indexPath) as! CharacterCell
      
      let character = self.allCharacters![indexPath.row]
      cell.name.text = character.name!
      cell.universe.text = character.universe!
      downloadImage(url: URL(string: character.imageURL ?? optionalImage)!, image: cell.image)
      cell.rectangle.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
      cell.rectangle.layer.shadowOffset = .zero
      cell.rectangle.layer.shadowRadius = 8
      cell.rectangle.layer.shadowOpacity = 1
      cell.rectangle.layer.shadowPath = UIBezierPath(rect: cell.rectangle.bounds).cgPath
      cell.rectangle.layer.shouldRasterize = true
      
      return cell
    }else if collectionView == self.filterCollectionView{
      
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterButtonCell", for: indexPath) as! FilterButtonCell
      
      //cell.button.titleLabel?.text = gamesList[indexPath.row]
      cell.button.setTitle(gamesList[indexPath.row], for: .normal)
      cell.button.tag = indexPath.row
      cell.button.layer.borderColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
      if cell.button.state == .normal{
        cell.button.tintColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        cell.button.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
      }
      cell.button.addTarget(self, action: #selector(self.buttonClicked), for: .touchUpInside)
      return cell
      
    } else{
      
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CharacterSmallCell", for: indexPath) as! CharacterSmallCell
      
      var character = self.newCharacters[indexPath.row]
      
      if collectionView == newCollectionView {
        cell.rectangle.layer.borderColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        cell.rectangle.layer.borderWidth = 1
      }else{
        cell.rectangle.layer.borderWidth = 0
        character = self.popularCharacters![indexPath.row]
      }
      cell.name.text = character.name!
      cell.universe.text = character.universe!
      
      downloadImage(url: URL(string: character.imageURL ?? optionalImage)!, image: cell.imageView)
      
      cell.rectangle.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
      cell.rectangle.layer.shadowOffset = .zero
      cell.rectangle.layer.shadowRadius = 8
      cell.rectangle.layer.shadowOpacity = 1
      cell.rectangle.layer.shadowPath = UIBezierPath(rect: cell.rectangle.bounds).cgPath
      cell.rectangle.layer.shouldRasterize = true
      
      return cell
    }
    
  }
  
}


