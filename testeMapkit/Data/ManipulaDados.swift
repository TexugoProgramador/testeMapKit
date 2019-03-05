//
//  ManipulaDados.swift
//  testeMapkit
//
//  Created by humberto Lima on 05/03/19.
//  Copyright © 2019 humberto Lima. All rights reserved.
//

import UIKit
import CoreData

class ManipulaDados: NSObject {

    var pontos:[NSManagedObject] = []
    
    
    func salvaPonto(pontoSelecionado: Ponto) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Locais", in: managedContext)!
        let novoPonto = NSManagedObject(entity: entity,  insertInto: managedContext)
        
        novoPonto.setValue(pontoSelecionado.titulo, forKeyPath: "nome")
        novoPonto.setValue(pontoSelecionado.subtitulo, forKeyPath: "detalhe")
        novoPonto.setValue(pontoSelecionado.latitude, forKeyPath: "latitude")
        novoPonto.setValue(pontoSelecionado.longitude, forKeyPath: "longitude")
        
        do {
            try managedContext.save()
            pontos.append(novoPonto)
        } catch let error as NSError {
            print("Não foi possível salvar erro. \(error), \(error.userInfo)")
        }
    }
    
    func retonaPontos() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Locais")
        
        do {
            pontos = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Dados não encontrados \(error), \(error.userInfo)")
        }
    }
    
    func deletaPonto(pontoDeletar: NSManagedObject, onSuccess:@escaping (Bool) -> Void) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.delete(pontoDeletar)
        
        do {
            try managedContext.save()
            self.retonaPontos()
            onSuccess(true)
        } catch  {
            onSuccess(false)
        }
    }
    
}
