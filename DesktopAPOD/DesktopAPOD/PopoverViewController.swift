//
//  PopoverViewController.swift
//  DesktopAPOD
//
//  Created by Richard Ash on 4/29/17.
//  Copyright © 2017 Richard. All rights reserved.
//

import Cocoa

protocol PopoverViewControllerDelegate: class {
  func popoverViewController(_ popoverViewController: PopoverViewController, settingsWasTapped button: NSButton?)
}

class PopoverViewController: NSViewController {
  
  // MARK: - Static Properties
  
  static let identifier = "PopoverViewController"
  
  // MARK: - IB Outlet Properties
  
  @IBOutlet weak var imageView: NSImageView!
  @IBOutlet weak var dateTextField: NSTextField!
  @IBOutlet weak var refreshButton: NSButton!
  @IBOutlet weak var backgroundButton: BackgroundButton!
  @IBOutlet weak var spinner: Spinner!
  @IBOutlet weak var errorView: ErrorView!
  
  // MARK: - Properties
  
  var apiClient: APIClient!
  var apodFileManager: APODFileManager!
  var apod = APOD.loadAPOD()
  weak var delegate: PopoverViewControllerDelegate?
  
  // MARK: - Overridden Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    dateTextField.stringValue = ""
    view.layer?.backgroundColor = NSColor.black.cgColor
    spinner.isHidden = true

    if let apod = apod {
      configureUI(with: apod)
    } else {
      spinner.isHidden = false
      refreshAPOD()
    }
  }
  
  override func viewWillDisappear() {
    super.viewWillDisappear()
    spinner.isHidden = true
  }
  
  // MARK: - IB Action Methods
  
  @IBAction func refresh(_ sender: Any?) {
    if spinner.isHidden {
      spinner.showAnimated()
      refreshAPOD()
    }
  }
  
  @IBAction func goToSettings(_ sender: NSButton?) {
    if let apod = apod {
      APOD.save(apod)
    }
    
    delegate?.popoverViewController(self, settingsWasTapped: sender)
  }
  
  @IBAction func updateBackground(_ sender: NSButton?) {
    if let apod = apod {
      self.updateDesktopBackground(with: apod)
    }
  }
  
  // MARK: - Methods
  
  func configureUI(with apod: APOD) {
    imageView.image = apod.image
    dateTextField.stringValue = apod.formattedDate
  }
  
  func refreshAPOD() {
    getAPOD { [weak self] (apod) in
      self?.apod = apod
      DispatchQueue.main.async {
        self?.configureUI(with: apod)
        self?.spinner.hideAnimated()
      }
    }
  }
  
  func updateDesktopBackground(with apod: APOD) {
    apodFileManager.createAPODDirectory()
    apodFileManager.removeFilesFromAPODDirectory()
    
    do {
      try apodFileManager.saveAPODImage(apod)
      try apodFileManager.updateDesktopImage(from: apod)
    } catch {
      backgroundButton.animateUpdateFailed()
    }
    
    backgroundButton.animateUpdateSucceeded()
  }
  
  // MARK: - Private Methods
  
  private func getAPOD(completion: @escaping (APOD) -> Void) {
    switch apiClient.getAPODData() {
    case .success(let apodData):
      apiClient.downloadImage(from: apodData.imageURL) { (image) in
        guard let image = image else { return }
        let apod = APOD(title: apodData.title, image: image, date: Date())
        completion(apod)
      }
    case .failure(let error as APIClient.APIError):
      handleAPIClientError(error)
    case .failure(let error):
      handleAPIClientError(.other("\(error)"))
    }
  }
  
  private func handleAPIClientError(_ error: APIClient.APIError) {
    errorView.animate(with: error) { [weak self] in
      self?.spinner.isHidden = true
    }
  }
}
