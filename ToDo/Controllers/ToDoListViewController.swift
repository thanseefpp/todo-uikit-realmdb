import UIKit
import RealmSwift
import ChameleonFramework

class ToDoListViewController: SwipeTableViewController {
    
    @IBOutlet var navBarTitle: UINavigationItem!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tabelView: UITableView!
    let realm = try! Realm()
    //db initialized
    var todoDatas: Results<TodoModel>?
    
    //now only show the items when selectedcategory data get.
    var selectedCategory : Category? {
        didSet {
            //to fetch all the items in database.
            loadItems()
            tabelView.rowHeight = 80.0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorColor = .none
        //        self.navigationController?.hidesNavigationBarHairline = true
        //        print(Realm.Configuration.defaultConfiguration.fileURL as Any)
    }
    //MARK: - navbar color update
    
    override func viewWillAppear(_ animated: Bool) {
        navBarTitle.title = "SubTask"
        if let colorHex = selectedCategory?.colorpicked {
            guard let navBar = navigationController?.navigationBar else {fatalError("navigation controller property not accessible")}
            
            if let navbarColour = UIColor(hexString: colorHex) {
//                navBar.backgroundColor = navbarColour
                navBar.backgroundColor = navbarColour
                navBar.tintColor = ContrastColorOf(navbarColour, returnFlat: true)
                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navbarColour, returnFlat: true)]
                
                searchBar.barTintColor = navbarColour
                
                
            }
        }
    }
    
    
    //MARK: - Table view Datasource method
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoDatas?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        //optional binding
        if let item = todoDatas?[indexPath.row] {
            //            print(item.done)
            cell.textLabel?.text = item.title
            //cell color changing
            //            FlatRed().darken(byPercentage: CGFloat(indexPath.row)/CGFloat(todoDatas!.count)) // single color plat
            if let colour = UIColor(hexString: selectedCategory!.colorpicked)?.lighten(byPercentage: CGFloat(indexPath.row)/CGFloat(todoDatas!.count)) {
                cell.backgroundColor = colour
                cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
            }
            //
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
                        if textField.text != "" {
                            newItems.title = textField.text!
                            newItems.done = false
                            newItems.dateTime = Date()
                            currentCategory.items.append(newItems)
                            self.realm.add(currentCategory)
                        }else{
                            alert.endAppearanceTransition()
                        }
                        
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
        todoDatas = selectedCategory?.items.sorted(byKeyPath: "dateTime", ascending: true)
//        print(todoDatas!)
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let itemDelete = self.todoDatas?[indexPath.row] {
            do {
                try self.realm.write({
                    self.realm.delete(itemDelete)
                })
            }catch{
                print("Error during item deleting \(error)")
            }
        }
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
