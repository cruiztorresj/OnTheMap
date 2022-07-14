//
//  OnTheMapTableViewController.swift
//  OnTheMap
//
//  Created on 2/6/17.
//

import UIKit

class OnTheMapTableViewController: UITableViewController, OnTheMapCommon {
    
    var students: [StudentInformation]!
    private var studentCellIdentifier = Constants.CellIdentifier
    
    @IBOutlet private weak var studentsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        studentsTableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refreshStudentData(self)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: studentCellIdentifier, for: indexPath)
        let studentForRow = students[(indexPath as NSIndexPath).row]
        cell.imageView?.image = UIImage(imageLiteralResourceName: Constants.PinImageString)
        cell.textLabel?.text = studentForRow.name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        studentsTableView.deselectRow(at: indexPath, animated: true)
        let studentForRow = students[(indexPath as NSIndexPath).row]
        openURLInBrowser(self, withURL: studentForRow.url!)
    }
    
    @IBAction private func userPressLogout(_ sender: UIBarButtonItem) {
        endUdacitySession(self as UIViewController )
    }
    
    @IBAction private func userPressRefresh(_ sender: UIBarButtonItem) {
        refreshStudentData(self)
    }
    
    func updateViewInformation() {
        initStudentsArray()
        studentsTableView.reloadData()
    }
}
