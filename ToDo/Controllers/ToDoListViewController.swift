import UIKit
import RealmSwift

class ToDoListViewController: UITableViewController {
    
    @IBOutlet var tabelView: UITableView!
    let realm = try! Realm()
    //db initialized
    var todoDatas: Results<TodoModel>?
    
    //now only show the items when selectedcategory data get.
    var selectedCategory : Category? {
        didSet {
            //to fetch all the items in database.
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        print(Realm.Configuration.defaultConfiguration.fileURL as Any)
    }
    
    //MARK: - Table view Datasource method
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoDatas?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let arrayData = itemArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
//        cell.textLabel?.text = "item.title"
        //optional binding
        if let item = todoDatas?[indexPath.row] {
//            print(item.done)
            cell.textLabel?.text = item.title
            //Ternary operator
            //assigne value = condition ? expression1 : expression2
            cell.accessoryType = item.done ? .checkmark : .none
        }else{
            cell.textLabel?.text = "No items added"
        }
        return cell
    }
    
    //MARK: - Tableview Delegate Method
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let itemsNew = todoDatas?[indexPath.row] {
            do{
                try realm.write({
//                    realm.delete(itemsNew) // delete
//                    itemsNew.title = "changed" // update
                    itemsNew.done = !itemsNew.done //update
                })
            }catch{
                print("error during done status change \(error)")
            }
        }
        self.tableView.reloadData()
        
        // animation for deselecting items
        tabelView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Add items button section
    
    @IBAction func AddButtonPressed(_ sender: UIBarButtonItem) {
        
        // created a local variable to store the items from alert box
        var textField = UITextField()
        
        // here creating a alert controll view to triger
        let alert = UIAlertController(title: "Add New Task", message: "Item added to ToDo List ", preferredStyle: .alert)
        
        // action to the alert view
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //this place only execute when the user press the add item button
            
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write{
                        let newItems = TodoModel()
                        newItems.title = textField.text!
                        newItems.done = false
                        newItems.dateTime = Date()
                        currentCategory.items.append(newItems)
                        self.realm.add(currentCategory)
                    }
                }catch{
                    print("Error during items adding \(error)")
                }
            }
            self.tabelView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            // here is assiging alerttextfield user added data to the variable.
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        // to show the aler message with animation.
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - save items to db, Data Manipulation
    
    //sort items and load data bastes on the category we have choose from previous page.
    func loadItems() {
        todoDatas = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        //        print(todoDatas!)
        tableView.reloadData()
    }
}


//MARK: - Search bar method

extension ToDoListViewController : UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //sorting and searching for an item using realm orm.
        todoDatas = todoDatas?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateTime", ascending: true)
        tabelView.reloadData()
    }

    // this delegate method will always trigger when the user type text or remove from searchbar.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            // to dismiss the keyboard.
            //using dispathchqueue to run thread as main.
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }

}
