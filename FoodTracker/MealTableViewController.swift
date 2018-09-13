//
//  MealTableViewController.swift
//  FoodTracker
//
//  Created by Mario Ban on 24.04.16.
//  Copyright © 2016 Mario Ban. All rights reserved.
//

import UIKit

class MealTableViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    
    
    // MARK: Properties
    var searchController = UISearchController(searchResultsController: nil)
    var meals = [Meal]()
    var filterMeals = [Meal]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filterMeals = meals
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.delegate = self
        searchController.searchBar.scopeButtonTitles = ["All"]
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // Use the edit button item provided by the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem
        
        // Load any saved meals, otherwise load sample data.
        if let savedMeals = loadMeals() {
            meals += savedMeals
            printMeals() // Debug
        }
        else {
            // Load the sample data.
            loadSampleMeals()
        }
    }
    //MARK: Dismiss search in navigation
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchController.dismiss(animated: false, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    func loadSampleMeals() {
        let photo1 = UIImage(named: "meal1")!
        let meal1 = Meal(name: "Caprese Salad", photo: photo1, rating: 4)!
        
        let photo2 = UIImage(named: "meal2")!
        let meal2 = Meal(name: "Chicken and Potatoes", photo: photo2, rating: 5)!
        
        let photo3 = UIImage(named: "meal3")!
        let meal3 = Meal(name: "Pasta with Meatballs", photo: photo3, rating: 3)!
        
        meals += [meal1, meal2, meal3]
        printMeals() // Debug
    }
    
    func printMeals() {
        var i = 0
        for meal in meals {
            print("meal.name: [\(i)] '\(meal.name)'") // Debug
            i += 1
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filtering() {
            return filterMeals.count
        }
            return meals.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "MealTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MealTableViewCell
        
        // Fetches the appropriate meal for the data source layout.
        let meal: Meal
        if filtering(){
            meal = filterMeals[indexPath.row]
        }else{
            meal = meals[indexPath.row]
        }
        cell.nameLabel.text = meal.name
        cell.photoImageView.image = meal.photo
        cell.ratingControl.rating = meal.rating
        
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        print("at: \(indexPath.row)") // Debug
        if editingStyle == .delete {
            // Delete the row from the data source
            if filtering() {
                filterMeals.remove(at: indexPath.row)
            }else{
                meals.remove(at: indexPath.row)
            }
            saveMeals()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to toIndexPath: IndexPath) {
        print("from: \(fromIndexPath.row), to: \(toIndexPath.row)") // Debug
        let meal = meals.remove(at: fromIndexPath.row)
        meals.insert(meal, at: toIndexPath.row)
        saveMeals()
    }
    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            let mealDetailViewController = segue.destination as! MealViewController // If the cast is unsuccessful, the app should crash at runtime.
            
            // Get the cell that generated this segue.
            if let selectedMealCell = sender as? MealTableViewCell {
                let indexPath = tableView.indexPath(for: selectedMealCell)!
                let selectedMeal: Meal
                if filtering() {
                    selectedMeal = filterMeals[indexPath.row]
                }else{
                    selectedMeal = meals[indexPath.row]
                }
                mealDetailViewController.meal = selectedMeal
            }
        }
        else if segue.identifier == "AddItem" {
            print("Adding new meal.")
        }
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    // MARK: Actions
    
    @IBAction func unwindToMealList(_ sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? MealViewController, let meal = sourceViewController.meal {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing meal.
                if filtering() {
                filterMeals[selectedIndexPath.row] = meal
                }else{
                meals[selectedIndexPath.row] = meal
                }
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }
            else {
                // Add a new meal.
                let newIndexPath = IndexPath(row: meals.count, section: 0)
                if filtering() {
                filterMeals.append(meal)
                }else{
                meals.append(meal)
                }
                tableView.insertRows(at: [newIndexPath], with: .bottom)
            }
            // Save the meals.
            saveMeals()
        }
    }
    
    // MARK: NSCoding
    
    func saveMeals() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(meals, toFile: Meal.ArchiveURL.path)
        if !isSuccessfulSave {
            print("Failed to save meals...")
        }
        printMeals() // Debug
    }
    
    func loadMeals() -> [Meal]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Meal.ArchiveURL.path) as? [Meal]
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    func filtering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
    
    //MARK: Func searchbar delegate
    func searchBar (_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope:Int ){
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
    
    func filterContentForSearchText (_ searchText: String, scope: String = "All") {
        filterMeals = meals.filter {(item: Meal) in
            let doesCategoryMatch = (scope == "All") || (item.name == scope)
            if searchBarIsEmpty(){
                return doesCategoryMatch
            }else{
                return doesCategoryMatch && item.name.lowercased().contains(searchText.lowercased())
            }
        }
        tableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
       let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
}
