import UIKit
import RealmSwift

class CategoryTableViewController: UITableViewController {
    // db initialising
    let realm = try! Realm()
    
    //dynamic query store data type variable.
    var categoryField: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    //MARK: - TableView DataSource Methods
    
    // Return the number of rows for the table.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryField?.count ?? 1 // nil coalescing operator.
    }
    
    // Provide a cell object for each row.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Fetch a cell of the appropriate type.
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        // Configure the cell’s contents.
        cell.textLabel?.text = categoryField?[indexPath.row].name ?? "No Category added"
        
        return cell
    }
    
    //MARK: - add new categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        //created a variable to store data from alertbox
        var alertTextField = UITextField()
        
        //alert triger
        let alert = UIAlertController(title: "Add Category", message: "Add new category for items", preferredStyle: .alert)
        
        //alert box action
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            //this place only execute when the user press the add item button
            
            //in realm db we can direcly initilise object with just class name
            let newCategory = Category()
            newCategory.name = alertTextField.text!
            self.save(category: newCategory)
        }
        //action
        alert.addAction(action)
        
        //place holder to the text box inside the alertbox.
        alert.addTextField { (addTextField) in
            addTextField.placeholder = "create new category"
            alertTextField = addTextField
        }
        // to show the aler message with animation.
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - TableView Delegate Methods
    
    //selected rows will trigger
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //this method is used to go next segue by the identifier name.
        performSegue(withIdentifier: "goToItems", sender: self)
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
}
