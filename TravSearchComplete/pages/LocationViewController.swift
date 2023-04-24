//
//  LocationViewController.swift
//  TravSearchComplete
//


import UIKit

// die Länderansicht, zugriff auf verschiedne Länder
class LocationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var callback : ((String) -> Void)?
    var countryList = [String]()
    var filteredCountryList : [String]!
    var selectedCountry : String = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        parseJSON()
    }
    
    
    // die json datei wird ausgelesen, wo alle länder sind
    // zugriff auf alle länder
    private func parseJSON(){
        if let url = Bundle.main.url(forResource: "countries", withExtension: "json"){
            
            var countryData = [Country]()
            do {
                let jsonData = try Data(contentsOf: url)
                countryData = try JSONDecoder().decode([Country].self, from: jsonData)
                for country in countryData {
                    countryList.append(country.name)
                }
                filteredCountryList = countryList
            }catch {
                print(error)
            }
        }
    }
    
    

    
    // wie viele Zellen in der tableview angezeigt werden, hier: filteredCountrylist
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCountryList.count
    }
    // was in der Zelle alles angezeigt werden soll auf der lovationview
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = filteredCountryList[indexPath.row]
        return cell
    }

    // wenn wir das ausgewählte land wieder zu uploadseite zurückzuschicken
    // dismiss heißt die liste wo man was auswählt schließt sich und wir sehen die upload seite
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let countryData = filteredCountryList[indexPath.row]
        selectedCountry = countryData
        callback?(selectedCountry)
        self.dismiss(animated: true, completion: nil)
       
    }
    // die suchleiste für das suchen nach ländern
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredCountryList = []
        if searchText == "" {
            filteredCountryList = countryList
        }else {
            for country in countryList {
                if country.lowercased().contains(searchText.lowercased()){
                    filteredCountryList.append(country)
                }
            }
        }
        
        tableView.reloadData()
    }
    
    

}





