//
//  MapaViewController.swift
//  testeMapkit
//
//  Created by humberto Lima on 04/03/19.
//  Copyright © 2019 humberto Lima. All rights reserved.
//

import UIKit
import MapKit

class MapaViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var botaoTipo: UIButton!
    
    @IBOutlet var gesto: UILongPressGestureRecognizer!
    @IBOutlet weak var mapaUsuario: MKMapView!
    var localUsuario = CLLocationManager()
    
    var desenhaRota = Bool()
    var pontoSelecionado = MKPointAnnotation()
    
    var mapaCentralizado = false
    
    var isAndando = true
    var ultimaRota = MKPolyline()
    
    override func viewDidAppear(_ animated: Bool) {
        mapaCentralizado = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gerenciaLocalizacaoUsuario()
        if desenhaRota {
            self.desenhaRotas()
            self.botaoTipo.alpha = 1
        }else{
            self.botaoTipo.alpha = 0
        }
    }
    
    func gerenciaLocalizacaoUsuario() {
        localUsuario.delegate = self
        localUsuario.desiredAccuracy = kCLLocationAccuracyBest
        localUsuario.requestWhenInUseAuthorization()
        localUsuario.startUpdatingLocation()
    }
    
    func alerta(title: String, mensagem:String){
        let alert = UIAlertController(title: title, message: mensagem, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func marcar(_ sender: UILongPressGestureRecognizer) {
        if gesto.state == .began {
            let pontoSelecionado = gesto.location(in: mapaUsuario)
            let coordenadas = mapaUsuario.convert(pontoSelecionado, toCoordinateFrom: mapaUsuario)
            let localizacao = CLLocation(latitude: coordenadas.latitude, longitude: coordenadas.longitude)
            
            CLGeocoder().reverseGeocodeLocation(localizacao) { (local, erro) in
                if erro == nil {
                    if let dadosLocal = local?.first {
                        self.alertaPonto(dados: dadosLocal, coordenadas: coordenadas)
                    }
                }else{
                    print(erro ?? "Erro")
                }
            }
        }
    }
    
    func alertaPonto(dados: CLPlacemark, coordenadas: CLLocationCoordinate2D) {
       
        let alert = UIAlertController(title: "Aviso", message: "Deseja salvar esse ponto?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Não", style: UIAlertAction.Style.default, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Sim", style: UIAlertAction.Style.default, handler: { (UIAlertAction) in
            let ponto = MKPointAnnotation()
            ponto.coordinate.latitude = coordenadas.latitude
            ponto.coordinate.longitude = coordenadas.longitude
            ponto.title = dados.name
            
            var pontoMarcado = Ponto()
            pontoMarcado.titulo = dados.name ?? ""
            pontoMarcado.latitude = coordenadas.latitude
            pontoMarcado.longitude = coordenadas.longitude
            
            if let endereco = dados.thoroughfare {
                ponto.subtitle = endereco
                pontoMarcado.subtitulo = endereco
            }
            
            self.mapaUsuario.addAnnotation(ponto)
            manipulaDado.salvaPonto(pontoSelecionado: pontoMarcado)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func desenhaRotas() {
        mapaUsuario.removeOverlay(ultimaRota) // limpa as rotas desenhas antes no mapa
        
        mapaUsuario.addAnnotation(pontoSelecionado)
        
        let localizacao = CLLocationCoordinate2D(latitude: localUsuario.location!.coordinate.latitude , longitude: localUsuario.location!.coordinate.longitude)
        let destino = CLLocationCoordinate2D(latitude:pontoSelecionado.coordinate.latitude , longitude: pontoSelecionado.coordinate.longitude)
        
        let placeMarkUsuario = MKPlacemark(coordinate: localizacao)
        let placeMarkDestilo = MKPlacemark(coordinate: destino)
        
        let direcoes = MKDirections.Request()
        direcoes.source = MKMapItem(placemark: placeMarkUsuario)
        direcoes.destination = MKMapItem(placemark: placeMarkDestilo)
        
        if isAndando {
            direcoes.transportType = .walking
        }else{
            direcoes.transportType = .automobile
        }
        
        let direcao = MKDirections(request: direcoes)
        direcao.calculate { (response, erro) in
            guard let responseRequest = response else {
                if erro != nil {
                    self.alerta(title: "Aviso", mensagem: "Erro ao desenhar rota")
                }
                return
            }
            
            let rota = responseRequest.routes[0]
            self.ultimaRota = rota.polyline
            self.mapaUsuario.addOverlay(self.ultimaRota, level: .aboveRoads)
        }
        self.mapaUsuario.delegate = self
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 4.0
        return renderer
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !mapaCentralizado {
            let localizacaoUsuario: CLLocation = locations.last!
            
            let latitude: CLLocationDegrees = localizacaoUsuario.coordinate.latitude
            let longitude: CLLocationDegrees = localizacaoUsuario.coordinate.longitude
            let deltaLatitude: CLLocationDegrees = 0.01
            let deltaLongitude: CLLocationDegrees = 0.01
            
            let coordenadas: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let areaVisualizacao: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: deltaLatitude, longitudeDelta: deltaLongitude)
            
            let regiao: MKCoordinateRegion = MKCoordinateRegion(center: coordenadas, span: areaVisualizacao)
            mapaUsuario.setRegion(regiao, animated: true)
            mapaUsuario.showsUserLocation = true
            mapaCentralizado = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status != .authorizedWhenInUse {
            alerta(title: "Aviso", mensagem: "Para usar este aplicativo é necessário sua acesso a sua localização")
        }
    }
    
    @IBAction func mudarLocomocao(_ sender: UIButton) {
        let alert = UIAlertController(title: "", message: "Qual meio de locomoção?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Andando", style: UIAlertAction.Style.default, handler: { (UIAlertAction) in
            self.isAndando = true
            self.desenhaRotas()
        }))
        
        alert.addAction(UIAlertAction(title: "Dirigindo", style: UIAlertAction.Style.default, handler: { (UIAlertAction) in
            self.isAndando = false
            self.desenhaRotas()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}
