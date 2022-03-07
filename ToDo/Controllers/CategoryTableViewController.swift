import UIKit
import RealmSwift
import ChameleonFramework

class CategoryTableViewController: SwipeTableViewController {
    // db initialising
    let realm = try! Realm()
    
    @IBOutlet var tableview: UITableView!
    //dynamic query store data type variable.
    var categoryField: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.setStatusBarStyle(UIStatusBarStyleContrast)
//        self.navigationController?.setThemeUsingPrimaryColor(.green, with: .dark)
//        
//        print(Realm.Configuration.defaultConfiguration.fileURL as Any)
        loadData()
        tableView.rowHeight = 80.0
        tableView.separatorColor = .none
    }
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else {fatalError("navigation controller property not accessible")}
        if let navbarColour = UIColor(hexString: "EFFFFD") {
            navBar.backgroundColor = navbarColour
            navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navbarColour, returnFlat: true)]
//            self.navigationController?.hidesNavigationBarHairline = true
        }
    }
    
    //MARK: - TableView DataSource Methods
    
    // Return the number of rows for the table.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryField?.count ?? 1 // nil coalescing operator.
    }
    
    // Provide a cell object for each row.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // calling cellfor row from swipetableview controller
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let category = categoryField?[indexPath.row] {
            
            // assinging text and desc from both field to cellsfields.
            cell.textLabel?.text = category.name
            
            guard let CategoryColor = UIColor(hexString: category.colorpicked) else { fatalError("color not getting error")}
            //cell.detailTextLabel?.text = categoryField?[indexPath.row].descData ?? "no descrption added"
            cell.backgroundColor = CategoryColor
            cell.textLabel?.textColor = ContrastColorOf(CategoryColor, returnFlat: true)
        }
        return cell
    }
    
    //MARK: - add new categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        //created a variable to store data from alertbox
        var alertTextField = UITextField()
//        var secondAlertText = UITextField()
        //alert triger
        let alert = UIAlertController(title: "Add Category", message: "Add new category for items", preferredStyle: .alert)
        
        //alert box action
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            //this place only execute when the user press the add item button
            let randomColorPicked = UIColor.randomFlat().hexValue()
            //in realm db we can direcly initilise object with just class name
            let newCategory = Category()
            if alertTextField.text != "" {
                newCategory.name = alertTextField.text!
                newCategory.colorpicked = randomColorPicked
                //newCategory.descData = secondAlertText.text!
                self.save(category: newCategory)
            }else{
                alert.endAppearanceTransition()
            }
            
        }
        //action
        alert.addAction(action)
        
        //place holder to the text box inside the alertbox.
        alert.addTextField { (addTextField) in
            addTextField.placeholder = "create new category"
            alertTextField = addTextField
        }
//        alert.addTextField { (addTextField) in
//            addTextField.placeholder = "create description"
//            secondAlertText = addTextField
//        }
        // to show the aler message with animation.
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - TableView Delegate Methods
    
    //selected rows will trigger
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //this method is used to go next segue by the identifier name.
        performSegue(withIdentifier: "goToItems", sender: self)
        tableview.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //destination downcasting.
        let destinationVC = segue.destination as! ToDoListViewController
        
        //created a optional binding indexpath to get the selected row
        if let indexPath = tableView.indexPathForSelectedRow {
            //assigning selected category to a category field value.
            destinationVC.selectedCategory = categoryField?[indexPath.row]
            //            print(destinationVC)
        }
    }
    
    
    
    //MARK: - Data Manipulation
    
    func save(category : Category) {
        do {
            //realm orm using to write data to db.
            try realm.write({
                realm.add(category)
            })
        }catch{
            print("Error occured while saving context \(error)")
        }
        tableView.reloadData()
    }
    
    func loadData(){
        
        //query to fetch items in this table.
        categoryField = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    //MARK: - swipe delet function override from super call
    
    override func updateModel(at indexPath: IndexPath) {
        if let itemDelete = self.categoryField?[indexPath.row] {
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

