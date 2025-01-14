/*
* Copyright (c) 2020, Nordic Semiconductor
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without modification,
* are permitted provided that the following conditions are met:
*
* 1. Redistributions of source code must retain the above copyright notice, this
*    list of conditions and the following disclaimer.
*
* 2. Redistributions in binary form must reproduce the above copyright notice, this
*    list of conditions and the following disclaimer in the documentation and/or
*    other materials provided with the distribution.
*
* 3. Neither the name of the copyright holder nor the names of its contributors may
*    be used to endorse or promote products derived from this software without
*    specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
* IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
* INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
* NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
* PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
* WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
* ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
* POSSIBILITY OF SUCH DAMAGE.
*/



import UIKit

class ServiceListViewController: UITableViewController {
    
    let dataProvider: ServiceProvider
    let serviceRouter: ServiceRouter
    
    private (set) var selectedService: ServiceId?
    
    init(dataProvider: ServiceProvider = DefaultServiceProvider(), serviceRouter: ServiceRouter) {
        self.dataProvider = dataProvider
        self.serviceRouter = serviceRouter
        super.init(style: .grouped)
        navigationItem.title = "Bottle appje"
    }
    
    required init?(coder aDecoder: NSCoder) {
        let errorMessage = "init(coder:) has not been implemented in ServiceListViewController"
        SystemLog(category: .ui, type: .fault).log(message: errorMessage)
        fatalError(errorMessage)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerCellNib(cell: ServiceTableViewCell.self)
        tableView.register(LinkTableViewCell.self, forCellReuseIdentifier: "LinkTableViewCell")
    }
    
}

extension ServiceListViewController {
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        dataProvider.sections[section].title
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        dataProvider.sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataProvider.sections[section].services.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch dataProvider.sections[indexPath] {
        case let ble as BLEService:
            let cell = tableView.dequeueCell(ofType: ServiceTableViewCell.self)
            cell.update(with: ble)
            return cell
        case let link as LinkService:
            let cell = tableView.dequeueCell(ofType: LinkTableViewCell.self)
            cell.update(with: link)
            return cell
        default:
            let errorMessage = "Incorrect cell type for indexPath \(indexPath)"
            SystemLog(category: .ui, type: .fault).log(message: errorMessage)
            fatalError(errorMessage)
        }
    }
}

extension ServiceListViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch dataProvider.sections[indexPath] {
        case let model as BLEService:
            guard let serviceId = ServiceId(rawValue: model.id) else {
                SystemLog(category: .ui, type: .debug).log(message: "Unknown service selected with id \(model.id)")
                break
            }
            selectedService = serviceId
            serviceRouter.showServiceController(with: serviceId)
        case let link as LinkService:
            tableView.deselectRow(at: indexPath, animated: true)
            serviceRouter.openLink(link)
        default:
            SystemLog(category: .ui, type: .debug).log(message: "Unknown Cell type selected")
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch traitCollection.userInterfaceIdiom {
        case .pad:
            return 100
        default:
            return 80
        }
    }
}
