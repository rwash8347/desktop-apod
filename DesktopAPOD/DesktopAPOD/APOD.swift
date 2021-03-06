//
//  APOD.swift
//  DesktopAPOD
//
//  Created by Richard Ash on 4/29/17.
//  Copyright © 2017 Richard. All rights reserved.
//

import Foundation
import Cocoa

class APOD: NSObject {
  
  // MARK: - Static Properties
  
  fileprivate static let Keys = (
    title: "apodTitle",
    apodImage: "apodImage",
    lastRefresh: "lastRefresh"
  )
  private static let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
  private static let archiveURL = documentDirectory.appendingPathComponent("apod")
  
  // MARK: - Properties
  
  let title: String
  let image: NSImage
  let lastRefresh: Date
  
  lazy var formattedDate: String = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .long
    dateFormatter.timeStyle = .long
    return dateFormatter.string(from: self.lastRefresh)
  }()
  
  // MARK: - Initialization
  
  init(title: String, image: NSImage, date: Date) {
    self.title = title
    self.image = image
    self.lastRefresh = date
  }
  
  required convenience init?(coder aDecoder: NSCoder) {
    guard let title = aDecoder.decodeObject(forKey: APOD.Keys.title) as? String else { return nil }
    guard let image = aDecoder.decodeObject(forKey: APOD.Keys.apodImage) as? NSImage else { return nil }
    guard let lastRefresh = aDecoder.decodeObject(forKey: APOD.Keys.lastRefresh) as? Date else { return nil }
    
    self.init(title: title, image: image, date: lastRefresh)
  }
  
  // MARK: - Static Methods
  
  static func save(_ apod: APOD) {
    let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(apod, toFile: archiveURL.path)
    print("Attempt to save was\(isSuccessfulSave ? "" : " not") successful")
  }
  
  static func loadAPOD() -> APOD? {
    return NSKeyedUnarchiver.unarchiveObject(withFile: archiveURL.path) as? APOD
  }
}

// MARK: - NSCoding

extension APOD: NSCoding {
  func encode(with aCoder: NSCoder) {
    aCoder.encode(title, forKey: APOD.Keys.title)
    aCoder.encode(image, forKey: APOD.Keys.apodImage)
    aCoder.encode(lastRefresh, forKey: APOD.Keys.lastRefresh)
  }
}

