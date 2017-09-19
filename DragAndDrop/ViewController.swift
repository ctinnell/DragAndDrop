//
//  ViewController.swift
//  DragAndDrop
//
//  Created by Tinnell, Clay on 9/19/17.
//  Copyright © 2017 Tinnell, Clay. All rights reserved.
//

import UIKit
import MobileCoreServices

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITableViewDragDelegate, UITableViewDropDelegate {
    
    var leftTableView = UITableView()
    var rightTableView = UITableView()
    
    var leftItems = [String](repeating: "Left", count: 20)
    var rightItems = [String](repeating: "Right", count: 20)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        leftTableView.dataSource = self
        rightTableView.dataSource = self
        
        leftTableView.frame = CGRect(x: 0, y: 40, width: 150, height: 400)
        rightTableView.frame = CGRect(x: 150, y: 40, width: 150, height: 400)
        
        leftTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        rightTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        view.addSubview(leftTableView)
        view.addSubview(rightTableView)
        
        leftTableView.dragDelegate = self
        leftTableView.dropDelegate = self
        rightTableView.dragDelegate = self
        rightTableView.dropDelegate = self
        
        leftTableView.dragInteractionEnabled = true
        rightTableView.dragInteractionEnabled = true
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case leftTableView:
            return leftItems.count
        case rightTableView:
            return rightItems.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        switch tableView {
        case leftTableView:
            cell.textLabel?.text = leftItems[indexPath.row]
        case rightTableView:
            cell.textLabel?.text = rightItems[indexPath.row]
        default:
            cell.textLabel?.text = "N/A"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let string = tableView == leftTableView ? leftItems[indexPath.row] : rightItems[indexPath.row]
        guard let data = string.data(using: .utf8) else { return [] }
        let itemProvider = NSItemProvider(item: data as NSData, typeIdentifier: kUTTypePlainText as String)
        return [UIDragItem(itemProvider: itemProvider)]
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        let destinationIndexPath: IndexPath
        
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        }
        else {
            let section = tableView.numberOfSections - 1
            let row = tableView.numberOfRows(inSection: section)
            destinationIndexPath = IndexPath(row: row, section: section)
        }
        
        //attempt to load strings from the drop connector
        coordinator.session.loadObjects(ofClass: NSString.self) { (items) in
            guard let strings = items as? [String] else { return }
            
            //create an empty array to track copied rows
            var indexPaths = [IndexPath]()
            
            for (index, string) in strings.enumerated() {
                let indexPath = IndexPath(row: destinationIndexPath.row + index, section: destinationIndexPath.section)
                
                if tableView == self.leftTableView {
                    self.leftItems.insert(string, at: indexPath.row)
                }
                else {
                    self.rightItems.insert(string, at: indexPath.row)
                }
                
                indexPaths.append(indexPath)
            }
            
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
}

