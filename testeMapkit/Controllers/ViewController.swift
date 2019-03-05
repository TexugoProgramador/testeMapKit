//
//  ViewController.swift
//  testeMapkit
//
//  Created by humberto Lima on 04/03/19.
//  Copyright © 2019 humberto Lima. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tabelaPesagens: UITableView!
    var indexSelecionado = Int()
    
    override func viewDidAppear(_ animated: Bool) {
        manipulaDado.retonaPontos()
        tabelaPesagens.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabelaPesagens.delegate = self
        tabelaPesagens.dataSource = self
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "selecionaPonto") {
            let vc = segue.destination as! MapaViewController
            vc.desenhaRota = true
            let pontoTemp = manipulaDado.pontos[indexSelecionado]
            let pontoSelecionado = MKPointAnnotation()
            pontoSelecionado.coordinate.latitude = pontoTemp.value(forKey: "latitude") as? Double ?? 0.0
            pontoSelecionado.coordinate.longitude = pontoTemp.value(forKey: "longitude") as? Double ?? 0.0
            pontoSelecionado.title = pontoTemp.value(forKey: "nome") as? String ??  ""
            pontoSelecionado.subtitle = pontoTemp.value(forKey: "detalhe") as? String ?? ""
            
            vc.pontoSelecionado = pontoSelecionado
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return manipulaDado.pontos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tabelaPesagens.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let pontoTemp = manipulaDado.pontos[indexPath.row]
        cell.detailTextLabel?.text = pontoTemp.value(forKey: "detalhe") as? String ?? ""
        cell.textLabel?.text = pontoTemp.value(forKey: "nome") as? String ?? ""
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCell.EditingStyle.delete) {
            
            let alert = UIAlertController(title: "Aviso", message: "Deseja deletar esse ponto?", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Não", style: UIAlertAction.Style.default, handler: nil))
            
            alert.addAction(UIAlertAction(title: "Sim", style: UIAlertAction.Style.default, handler: { (UIAlertAction) in
                manipulaDado.deletaPonto(pontoDeletar: manipulaDado.pontos[indexPath.row], onSuccess: { (ret) in
                    if ret {
                        self.tabelaPesagens.reloadData()
                    }
                })
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        indexSelecionado = indexPath.row
        performSegue(withIdentifier: "selecionaPonto", sender: self)
    }
    
}

