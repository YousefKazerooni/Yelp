//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIScrollViewDelegate {

    var businesses: [Business]!
    var businessesBackup: [Business]!
    var searchBar: UISearchBar!
    
    //flag for infinite scroll
    var isMoreDataLoading = false
    var loadMoreOffset = 20
    var loadingMoreView: InfiniteScrollActivityView?
    var selectedCategories: [String]?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //searchBar added programatically into the navigation bar
        searchBar = UISearchBar()
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        //After setting up the height using autolayout in the storyboard
        //we must specify here that the height must change
        //***must always be used in conjuction with estimatedrowheight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.hidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets
        
        
       

        Business.searchWithTerm("Restaurants", completion: { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
        
            for business in businesses {
                print(business.name!)
                print(business.address!)
            }
        })
        

/* Example of Yelp search with more search options specified
        Business.searchWithTerm("Restaurants", sort: .Distance, categories: ["asianfusion", "burgers"], deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            
            for business in businesses {
                print(business.name!)
                print(business.address!)
            }
        }
*/
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
        
        
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if businesses != nil {
            return businesses!.count
        } else {
            return 0
        }
    }
       
    
    
    

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BusinessCell", forIndexPath: indexPath) as! BusinessCell
        
        cell.business = businesses[indexPath.row]
        
        return cell
    }
    
    
    //Note: All credits for the following function
    //go to kmolo (Katherine Monoley)
    // This method updates filteredData based on the text in the Search Box
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        if(businessesBackup == nil) {
            businessesBackup = businesses
        }
        
        // When there is no text, filteredData is the same as the original data
        if searchText.isEmpty {
            businesses = businessesBackup
        } else {
            // The user has entered text into the search box
            // Use the filter method to iterate over all items in the data array
            // For each item, return true if the item should be included and false if the
            // item should NOT be included
            businesses = businesses.filter({(dataItem: Business) -> Bool in
                
                // If dataItem matches the searchText, return true to include it
                if dataItem.name!.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil {
                    return true
                } else {
                    return false
                }
            })
        }
        
        tableView.reloadData()
        
    }
    
    
    //************ showing the cancel button upon editing in the search bar
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    //*********** activating the cancel button
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        
        //After removing cancel we must reload the view
        businesses = businessesBackup
        self.tableView.reloadData()
        
    }
    
    //using api request to load more data
    func loadMoreData() {
        
       
        Business.searchWithTerm("Restaurants", sort: nil, categories: selectedCategories, deals: nil, completion: { (businesses: [Business]!, error: NSError!) -> Void in
            if error != nil {
                
                    self.loadingMoreView?.stopAnimating()
                    //TODO: show network error
                
            } else {
                
                    self.loadMoreOffset += 20
                    self.businessesBackup.appendContentsOf(businesses)
                    self.tableView.reloadData()
                    self.loadingMoreView?.stopAnimating()
                    self.isMoreDataLoading = false
                
            }
        })
    }
    
        

    
        
//        Business.searchWithTerm("restaurant", completion: { (businesses: [Business]!, error: NSError!) -> Void in
//            self.businesses = businesses
//            
//            //self.businesses.appendContentsOf(businesses)
//            // Update flag
//            self.isMoreDataLoading = false
//            
//            // Stop the loading indicator
//            self.loadingMoreView!.stopAnimating()
//            self.tableView.reloadData()
//        })
//    
//        
//    }
    
  
    
    
    
    //>>>>>>>>>>>>>>>>>>>>Infinite Scroll
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // Handle scroll behavior here
        if (!isMoreDataLoading) {
            
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.dragging) {
                
                isMoreDataLoading = true
                
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                
                // ... Code to load more results ...
                loadMoreData()
            }
        }
    }
      


    
       

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


}