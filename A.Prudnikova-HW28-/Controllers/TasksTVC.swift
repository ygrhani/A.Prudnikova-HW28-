//
//  TasksTVC.swift
//  A.Prudnikova-HW28-
//
//  Created by Ann Prudnikova on 16.01.23.
//

import UIKit
import RealmSwift

enum TasksTVCFlow {
    case addingNewTask
    case editingTask(task: Task)
}

struct TxtAlertData {
    
    let titleForAlert = "Task value"
    var messageForAlert: String
    let doneButtonForAlert: String
    let cancelTxt = "Cancel"
    
    let newTextFieldPlaceholder = "New task"
    let noteTextFieldPlaceholder = "Note"
    
    var taskName: String?
    var taskNote: String?
    
    init(tasksTVCFlow: TasksTVCFlow) {
        switch tasksTVCFlow {
            case .addingNewTask:
                messageForAlert = "Please insert new task value"
                doneButtonForAlert = "Save"
            case .editingTask(let task):
                messageForAlert = "Please edit your task"
                doneButtonForAlert = "Update"
                taskName = task.name
                taskNote = task.note
        }
    }
}

class TasksTVC: UITableViewController {
    
    var notificationToken: NotificationToken?
    var currentTasksList: TasksList?
    
    private var notCompletedTasks: Results<Task>!
    private var completedTasks: Results<Task>!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        filteringTasks()
        title = currentTasksList?.name
//        addTasksObserver()
        let addBtn = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addBarButtonSystemItemSelector))
        
        self.navigationItem.setRightBarButtonItems([addBtn, editButtonItem], animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? notCompletedTasks.count : completedTasks.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "Uncompleted tasks" : "Completed tasks"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let task = indexPath.section == 0 ? notCompletedTasks[indexPath.row] : completedTasks[indexPath.row]
        cell.textLabel?.text = task.name
        cell.detailTextLabel?.text = task.note
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let task = indexPath.section == 0 ? notCompletedTasks[indexPath.row] : completedTasks[indexPath.row]
        
        let deleteContextItem = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            StorageManager.deleteTask(task)
            self.filteringTasks()
        }
        
        let editContextItem = UIContextualAction(style: .destructive, title: "Edit") { _, _, _ in
            self.alertForAddAndUpdateList(tasksTVCFlow: .editingTask(task: task))
        }
        
        let doneText = task.isComplete ? "Undone" : "Done"
        let doneContextItem = UIContextualAction(style: .destructive, title: doneText) { _, _, _ in
            StorageManager.makeDone(task)
            self.filteringTasks()
        }
        
        editContextItem.backgroundColor = .systemBlue
        doneContextItem.backgroundColor = .systemGreen
        
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteContextItem, editContextItem, doneContextItem])
        
        return swipeActions
    }


    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        
        let elementToMove = fromIndexPath.section == 0 ? notCompletedTasks[fromIndexPath.row] : completedTasks[fromIndexPath.row]
        StorageManager.deleteToMove(currentTasksList!, task: elementToMove, indx: fromIndexPath.row)
        StorageManager.moveTask(currentTasksList!, task: elementToMove, indx: to.row)
    }


   
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }


    
    private func filteringTasks() {
        notCompletedTasks = currentTasksList?.tasks.filter("isComplete = false")
        completedTasks = currentTasksList?.tasks.filter("isComplete = true")
        tableView.reloadData()
    }
    
//    private func addTasksObserver() {
//        // Realm notification
//        notificationToken = currentTasksList?.tasks.observe { [weak self] change in
//            guard let self = self else { return }
//            switch change {
//            case .initial:
//                print("initial element")
//            case .update(_, let deletions, let insertions, let modifications):
//                print("deletions: \(deletions)")
//                print("insertions: \(insertions)")
//                print("modifications: \(modifications)")
//                if !modifications.isEmpty {
//
//                    let indexPathArray = self.createIndexPathArray(intArr: modifications, section: <#Int#>)
//                    self.tableView.reloadRows(at: indexPathArray, with: .automatic)
//                }
//                if !deletions.isEmpty {
//                    let indexPathArray = self.createIndexPathArray(intArr: deletions, section: 0)
//                    self.tableView.deleteRows(at: indexPathArray, with: .automatic)
//                }
//                if !insertions.isEmpty {
//                    let indexPathArray = self.createIndexPathArray(intArr: insertions, section: 0)
//                    self.tableView.insertRows(at: indexPathArray, with: .automatic)
//                }
//            case .error(let error):
//                print("error: \(error)")
//            }
//        }
//    }
//
//    private func createIndexPathArray(intArr: [Int], section: Int) -> [IndexPath] {
//        var indexPathArray = [IndexPath]()
//        for row in intArr {
//            indexPathArray.append(IndexPath.init(row: row, section: section))
//        }
//        return indexPathArray
//    }
}



extension TasksTVC {
    
    @objc private func addBarButtonSystemItemSelector() {
        alertForAddAndUpdateList(tasksTVCFlow: .addingNewTask)
    }
    
    private func alertForAddAndUpdateList(tasksTVCFlow: TasksTVCFlow) {
        
        let txtAlertData = TxtAlertData(tasksTVCFlow: tasksTVCFlow)
        
//        UIAlertController.showAlertWithTwoTF(tasksTVCFlow: txtAlertData) { txtAlertData in
//            // тут либо создаем новый либо редактируем
//            switch tasksTVCFlow {
//                case .addingNewTask:
//                    let task = Task()
//                    task.name = txtAlertData.taskName
//                    task.note = txtAlertData.taskNote
//                    guard let currentTasksList = self.currentTasksList else { return }
//                    StorageManager.saveTask(currentTasksList, task: task)
//                case .editingTask(let task):
//                    StorageManager.editTask(task,
//                                            newNameTask: txtAlertData.taskName,
//                                            newNote: txtAlertData.taskNote)
//            }
//        } cancelAction: {
//            // можем что то еще сделать
//        }

        let alert = UIAlertController(title: txtAlertData.titleForAlert,
                                      message: txtAlertData.messageForAlert,
                                      preferredStyle: .alert)
        
        /// UITextField-s
        var taskTextField: UITextField!
        var noteTextField: UITextField!
        
        alert.addTextField { textField in
            taskTextField = textField
            taskTextField.placeholder = txtAlertData.newTextFieldPlaceholder
            taskTextField.text = txtAlertData.taskName
        }

        alert.addTextField { textField in
            noteTextField = textField
            noteTextField.placeholder = txtAlertData.noteTextFieldPlaceholder
            noteTextField.text = txtAlertData.taskNote
        }

        /// Action-s

        let saveAction = UIAlertAction(title: txtAlertData.doneButtonForAlert,
                                       style: .default) { [weak self] _ in

            guard let newNameTask = taskTextField.text, !newNameTask.isEmpty,
                  let newNote = noteTextField.text, !newNote.isEmpty,
                  let self = self else { return }

            switch tasksTVCFlow {
                case .addingNewTask:
                    let task = Task()
                    task.name = newNameTask
                    task.note = newNote
                    guard let currentTasksList = self.currentTasksList else { return }
                    StorageManager.saveTask(currentTasksList, task: task)
                case .editingTask(let task):
                    StorageManager.editTask(task,
                                            newNameTask: newNameTask,
                                            newNote: newNote)
            }
            self.filteringTasks()
        }

        let cancelAction = UIAlertAction(title: txtAlertData.cancelTxt, style: .destructive)

        alert.addAction(saveAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }
}
