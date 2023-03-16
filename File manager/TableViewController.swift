//
//  TableViewController.swift
//  File manager
//
//  Created by Денис Штоколов on 16.03.2023.
//

import UIKit

class TableViewController: UITableViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    var url: URL
    
    var files: [URL] {
        return (try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil))!
    }
    
    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        layout()
    }
    
    private func layout() {
        let addFileButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(createNewImage))
        self.navigationItem.rightBarButtonItem = addFileButton
        navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
        navigationItem.title = "\(url.lastPathComponent)"
    }
    
    @objc private func createNewImage(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.editedImage] as? UIImage else { return }
        
        let alertController = UIAlertController(title: "Save image", message: nil, preferredStyle: .alert)
        alertController.addTextField { textfield in
            textfield.placeholder = "Enter image name"
        }
        
        let saveImageAction = UIAlertAction(title: "Save", style: .default) { action in
            if let imageName = alertController.textFields?[0].text,
               imageName != "",
               let data = image.pngData() {
                let imagePath = self.url.appendingPathComponent(imageName)
                FileManager.default.createFile(atPath: imagePath.path, contents: data, attributes: nil)
                self.tableView.reloadData()
            }
        }
        
        dismiss(animated: true)
        alertController.addAction(saveImageAction)
        present(alertController, animated: true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "cell")
        let item = files[indexPath.row]
        cell.detailTextLabel?.text = "Image"
        cell.textLabel?.text = item.lastPathComponent
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = files[indexPath.row]
            do {
                try FileManager.default.removeItem(at: item)
            } catch {
                print(error)
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
