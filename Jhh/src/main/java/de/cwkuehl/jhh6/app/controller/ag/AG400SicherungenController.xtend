package de.cwkuehl.jhh6.app.controller.ag

import de.cwkuehl.jhh6.api.dto.MaEinstellung
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.app.Jhh6
import de.cwkuehl.jhh6.app.base.BaseController
import de.cwkuehl.jhh6.app.base.DialogAufrufEnum
import de.cwkuehl.jhh6.app.base.Werkzeug
import de.cwkuehl.jhh6.server.FactoryService
import de.cwkuehl.jhh6.server.service.backup.Sicherung
import java.nio.file.Paths
import java.time.LocalDateTime
import java.util.ArrayList
import java.util.List
import javafx.beans.property.SimpleObjectProperty
import javafx.beans.property.SimpleStringProperty
import javafx.collections.FXCollections
import javafx.collections.ObservableList
import javafx.concurrent.Task
import javafx.fxml.FXML
import javafx.scene.control.Button
import javafx.scene.control.Label
import javafx.scene.control.TableColumn
import javafx.scene.control.TableView
import javafx.scene.control.TextArea
import javafx.scene.control.TextField
import javafx.scene.input.MouseEvent
import java.net.InetSocketAddress
import java.io.OutputStream
import java.io.IOException
import javafx.application.Platform
import java.util.Date
import java.nio.charset.Charset
import de.cwkuehl.jhh6.api.service.ServiceErgebnis
import de.cwkuehl.jhh6.api.message.Meldung
import java.io.ByteArrayOutputStream
import java.io.FileInputStream
import java.io.File
import java.security.MessageDigest
import java.util.Base64
import java.nio.charset.StandardCharsets

// HTTPS-Server
public class WkHttpsHandler implements com.sun.net.httpserver.HttpHandler {

	static int port0 = 4201
	static com.sun.net.httpserver.HttpServer server0
	static int port = 4202
	static com.sun.net.httpserver.HttpsServer server
	static String token = ''
	
    def static public void start(String token) throws Exception {

    	var f = new File('/opt/Haushalt/JHH6/cert/cert_key.pfx')
		if (f.exists && server === null) {
	        var keyStore = java.security.KeyStore.getInstance("JKS");
	        keyStore.load(new FileInputStream(f), newCharArrayOfSize(0));
	         
	        // Create key manager
	        var keyManagerFactory = javax.net.ssl.KeyManagerFactory.getInstance("SunX509");
	        keyManagerFactory.init(keyStore, newCharArrayOfSize(0));
	        var km = keyManagerFactory.getKeyManagers();
	         
	        // Create trust manager
	        var trustManagerFactory = javax.net.ssl.TrustManagerFactory.getInstance("SunX509");
	        trustManagerFactory.init(keyStore);
	        var tm = trustManagerFactory.getTrustManagers();
	         
	        // Initialize SSLContext
	        var sslContext = javax.net.ssl.SSLContext.getInstance("TLSv1.2");
	        sslContext.init(km,  tm, null);
	
			WkHttpsHandler::token = token
	        //var localhost = new InetSocketAddress("127.0.0.1", port);
	        var localhost = new InetSocketAddress(port);
	        server = com.sun.net.httpserver.HttpsServer.create(localhost,  0);
	        server.setHttpsConfigurator(new com.sun.net.httpserver.HttpsConfigurator(sslContext));
	        server.createContext("/", new WkHttpsHandler());
	        server.setExecutor(null);
	        server.start();
        }
		if (server0 === null) {
		    server0 = com.sun.net.httpserver.HttpServer.create(new InetSocketAddress(port0), 0)
	        var context = server0.createContext("/")
	        context.setHandler(new WkHttpsHandler)
	        server0.start	
		}
    }

	def static public void stop() {
        Platform.runLater([| {
        	if (server !== null) {
                server.stop(1)
                server = null
            }
        	if (server0 !== null) {
                server0.stop(1)
                server0 = null
            }
        }])
	}
	
	    override public void handle(com.sun.net.httpserver.HttpExchange he) throws IOException {
    	
        var request = he.requestURI
        var r = new ServiceErgebnis
        var path = request.path
        var options = false
        var response = ''
        var contentType = "text/html; charset=utf-8"
        if (path == '/stop') {
        	response = "Stop!"
        	WkHttpsHandler::stop
        } else if (path == '/favicon.ico') {
        	// nix
        } else if (he.requestMethod == 'OPTIONS') {
        	options = true // CORS
	      	he.getResponseHeaders().add("Access-Control-Allow-Methods", "POST, GET, OPTIONS");
	    	he.getResponseHeaders().add("Access-Control-Allow-Headers", "X-PINGOTHER, Content-Type")
	    	he.getResponseHeaders().add("Access-Control-Max-Age", "86400")
	    	var origin = he.requestHeaders.get("Origin")
	    	if (origin !== null && origin.length > 0) {
	    	    he.getResponseHeaders().add("Access-Control-Allow-Origin", origin.get(0))
	    	    he.getResponseHeaders().add("Vary", "Origin")
	    	}
        } else if (he.requestMethod == 'POST') {
        	var is = he.requestBody
        	var result = new ByteArrayOutputStream
        	var buffer = newByteArrayOfSize(1024)
        	var int length
        	while ((length = is.read(buffer)) != -1) {
        		result.write(buffer, 0, length)
        	}
			var body = result.toString("UTF-8")
			if (body != WkHttpsHandler::token)
	        	r.fehler.add(Meldung.Neu('''Unberechtigt: «body».'''))
	        else {	
	        	contentType = "application/json; charset=utf-8"
	        	var r1 = FactoryService::replikationService.getJsonDaten(Jhh6::serviceDaten, '', '')
	        	if (r.get(r1))
	        		response = r1.ergebnis
	        	//response = '''[{"a":"abc äöüÄÖÜß xyz", "body":"«body»"}]'''
        	}
        } else if (path == '/') {
        	//he.getResponseHeaders().add("Content-type", "text/html; charset=utf-8")
            response = '''<h1>Hällo!</h1><h2>Anfrage: «path»</h2><h3>«new Date»</h3>'''
        } else {
        	r.fehler.add(Meldung.Neu('''Unbekannte Resource: «path».'''))
        }
        var byte[] bytes
        var statuscode = 200 // OK
        if (!r.ok) {
        	contentType = "text/html; charset=utf-8"
        	response = r.fehler.get(0).meldung
        	//statuscode = 404 // Not Found
        	statuscode = 401 // Unauthorized
        }
        if (!options) {
	      	he.getResponseHeaders().add("Content-type", contentType)
	    	he.getResponseHeaders().add("Expires", "-1")
	    	he.getResponseHeaders().add("Cache-Control", "no-cache")
	    	he.getResponseHeaders().add("Pragma", "no-cache")
	    	//he.getResponseHeaders().add("Server", "Microsoft-IIS/10.0")
	    	//he.getResponseHeaders().add("Vary", "Accept-Encoding")
	    	//he.getResponseHeaders().add("Content-Encoding", "identity")
	    	//he.getResponseHeaders().add("Access-Control-Allow-Origin", "http://localhost:4200")
	    	var origin = he.requestHeaders.get("Origin")
	    	if (origin !== null && origin.length > 0) {
	    	    he.getResponseHeaders().add("Access-Control-Allow-Origin", origin.get(0))
	    	    he.getResponseHeaders().add("Vary", "Origin")
	    	}
    	}
        bytes = response.getBytes(Charset.forName("UTF-8"))
        he.sendResponseHeaders(statuscode, bytes.length)
        var OutputStream os = he.getResponseBody
        os.write(bytes)
        os.close
    }
	
}

/** 
 * Controller für Dialog AG400Sicherungen.
 */
class AG400SicherungenController extends BaseController<String> {

	@FXML Button aktuell
	@FXML Button neu
	@FXML Button kopieren
	@FXML Button aendern
	@FXML Button loeschen
	@FXML Label verzeichnisse0
	@FXML TableView<VerzeichnisseData> verzeichnisse
	@FXML TableColumn<VerzeichnisseData, Integer> colNr
	@FXML TableColumn<VerzeichnisseData, String> colSchluessel
	@FXML TableColumn<VerzeichnisseData, String> colWert
	@FXML TableColumn<VerzeichnisseData, LocalDateTime> colGa
	@FXML TableColumn<VerzeichnisseData, String> colGv
	@FXML TableColumn<VerzeichnisseData, LocalDateTime> colAa
	@FXML TableColumn<VerzeichnisseData, String> colAv
	ObservableList<VerzeichnisseData> verzeichnisseData = FXCollections::observableArrayList
	// @FXML Button sicherung
	// @FXML Button diffSicherung
	// @FXML Button rueckSicherung
	// @FXML Button abbrechen
	@FXML Label status0
	@FXML TextArea statusText
	// @FXML Button mandantKopieren
	// @FXML Button mandantRepKopieren
	@FXML Label mandant0
	@FXML TextField mandant

	/** 
	 * Abbruch-Objekt. 
	 */
	StringBuffer abbruch = new StringBuffer
	/** 
	 * Status zum Anzeigen. 
	 */
	StringBuffer status = new StringBuffer
	/** 
	 * Liste für Kopier-Fehler. 
	 */
	package List<String> kopierFehler = new ArrayList<String>
	/** 
	 * Maximale Anzahl Fehler. 
	 */
	int maxFehler = Sicherung::MAX_SICHERUNG_FEHLER
	/** 
	 * Zeit in Millisekunden, die sich die Dateien unterscheiden dürfen, um als gleich zu gelten.
	 */
	long diffZeit = Sicherung::MAX_SICHERUNG_DIFFZEIT

	/** 
	 * Daten für Tabelle Verzeichnisse.
	 */
	static class VerzeichnisseData extends TableViewData<MaEinstellung> {

		SimpleObjectProperty<Integer> nr
		SimpleStringProperty schluessel
		SimpleStringProperty wert
		SimpleObjectProperty<LocalDateTime> geaendertAm
		SimpleStringProperty geaendertVon
		SimpleObjectProperty<LocalDateTime> angelegtAm
		SimpleStringProperty angelegtVon

		new(MaEinstellung v) {

			super(v)
			nr = new SimpleObjectProperty<Integer>(v.mandantNr)
			schluessel = new SimpleStringProperty(v.schluessel)
			wert = new SimpleStringProperty(v.wert)
			geaendertAm = new SimpleObjectProperty<LocalDateTime>(v.geaendertAm)
			geaendertVon = new SimpleStringProperty(v.geaendertVon)
			angelegtAm = new SimpleObjectProperty<LocalDateTime>(v.angelegtAm)
			angelegtVon = new SimpleStringProperty(v.angelegtVon)
		}

		override String getId() {
			return '''«nr.get»'''
		}
	}

	/** 
	 * Initialisierung des Dialogs.
	 */
	override protected void initialize() {

		tabbar = 1
		super.initialize
		verzeichnisse0.setLabelFor(verzeichnisse)
		status0.setLabelFor(statusText)
		mandant0.setLabelFor(mandant)
		initAccelerator("A", aktuell)
		initAccelerator("N", neu)
		initAccelerator("C", kopieren)
		initAccelerator("E", aendern)
		initAccelerator("L", loeschen)
		initDaten(0)
		verzeichnisse.requestFocus
	}

    override void onHidden() {
      	WkHttpsHandler::stop
    	super.onHidden
    }

	/** 
	 * Model-Daten initialisieren.
	 * @param stufe 0 erstmalig, 1 aktualisieren, 2 Tabellen aktualisieren.
	 */
	override protected void initDaten(int stufe) {

		if (stufe <= 0) {
			mandant.setText(Global::intStr(serviceDaten.mandantNr))
		    // mandant.setText("3")
//		    var digest = MessageDigest.getInstance("SHA-256")
//			var hash = digest.digest(serviceDaten.benutzerId.getBytes(StandardCharsets.UTF_8))
//			var encoded = Base64.getEncoder().encodeToString(hash)
//		    WkHttpsHandler::start(encoded)
		    WkHttpsHandler::start(serviceDaten.benutzerId)
		}
		if (stufe <= 1) {
			var l = sicherungen
			getItems(l, null, [a|new VerzeichnisseData(a)], verzeichnisseData)
		}
		if (stufe <= 2) {
			initDatenTable
		}
	}

	/** 
	 * Tabellen-Daten initialisieren.
	 */
	def protected void initDatenTable() {

		verzeichnisse.setItems(verzeichnisseData)
		colNr.setCellValueFactory([c|c.value.nr])
		colSchluessel.setCellValueFactory([c|c.value.schluessel])
		colWert.setCellValueFactory([c|c.value.wert])
		colGv.setCellValueFactory([c|c.value.geaendertVon])
		colGa.setCellValueFactory([c|c.value.geaendertAm])
		colAv.setCellValueFactory([c|c.value.angelegtVon])
		colAa.setCellValueFactory([c|c.value.angelegtAm])
	}

	override protected void updateParent() {
		speichern
		onAktuell
	}

	def private void starteDialog(DialogAufrufEnum aufruf) {

		var VerzeichnisseData k = getValue2(verzeichnisse, !DialogAufrufEnum::NEU.equals(aufruf))
		var MaEinstellung e = if(k === null) null else k.data
		e = starteDialog(typeof(AG410SicherungController), aufruf, e)
		if (e !== null) {
			if (DialogAufrufEnum::NEU.equals(aufruf) || DialogAufrufEnum::KOPIEREN.equals(aufruf)) {
				e.setMandantNr(verzeichnisseData.size + 1)
				verzeichnisseData.add(new VerzeichnisseData(e))
			} else if (DialogAufrufEnum::AENDERN.equals(aufruf)) {
				k.schluessel.set(e.schluessel)
				k.wert.set(e.wert)
			} else if (DialogAufrufEnum::LOESCHEN.equals(aufruf)) {
				verzeichnisse.items.remove(k)
			}
		}
		speichern
	}

	/** 
	 * Event für Aktuell.
	 */
	@FXML def void onAktuell() {
		refreshTable(verzeichnisse, 1)
	}

	/** 
	 * Event für Rueckgaengig.
	 */
	@FXML def void onRueckgaengig() {
		get(Jhh6::rollback)
		onAktuell
	}

	/** 
	 * Event für Wiederherstellen.
	 */
	@FXML def void onWiederherstellen() {
		get(Jhh6::redo)
		onAktuell
	}

	/** 
	 * Event für Neu.
	 */
	@FXML def void onNeu() {
		starteDialog(DialogAufrufEnum::NEU)
	}

	/** 
	 * Event für Kopieren.
	 */
	@FXML def void onKopieren() {
		starteDialog(DialogAufrufEnum::KOPIEREN)
	}

	/** 
	 * Event für Aendern.
	 */
	@FXML def void onAendern() {
		starteDialog(DialogAufrufEnum::AENDERN)
	}

	/** 
	 * Event für Loeschen.
	 */
	@FXML def void onLoeschen() {
		starteDialog(DialogAufrufEnum::LOESCHEN)
	}

	/** 
	 * Event für Verzeichnisse.
	 */
	@FXML def void onVerzeichnisseMouseClick(MouseEvent e) {
		if (e.clickCount > 1) {
			onAendern
		}
	}

	/** 
	 * Event für Sicherung.
	 */
	@FXML def void onSicherung() {
		onSicherungTimer(false, false)
	}

	/** 
	 * Event für DiffSicherung.
	 */
	@FXML def void onDiffSicherung() {
		onSicherungTimer(true, false)
	}

	/** 
	 * Event für RueckSicherung.
	 */
	@FXML def void onRueckSicherung() {
		onSicherungTimer(false, true)
	}

	/** 
	 * Event für Abbrechen.
	 */
	@FXML def void onAbbrechen() {
		abbruch.append("Abbruch")
	}

	/** 
	 * Event für SQL-Sicherung.
	 */
	@FXML def void onSqlSicherung() {
		onSqlSicherungTimer
	}

	def private void onSqlSicherungTimer() {

		if (Werkzeug::showYesNoQuestion(Meldungen::M1010) === 0) {
			return;
		}
		var Task<Void> task = ([|
			status.setLength(0)
			abbruch.setLength(0)
			kopierFehler.clear
			onSicherungStatus
			onSicherungStatusTimer
			try {
				var d = Global.getDateiname("JHH6", true, true, "sql")
				var datei = Paths.get(Jhh6::einstellungen.tempVerzeichnis, d)
				var r = FactoryService::replikationService.sqlSicherung(serviceDaten, datei, status, abbruch)
				r.throwErstenFehler
			} catch (Exception ex) {
				status.setLength(0)
				status.append(Meldungen::M1033(ex.message))
			} finally {
				abbruch.append("Ende")
			}
			return null as Void
		] as Task<Void>)
		var th = new Thread(task)
		th.setDaemon(true)
		th.start
	}

	def private List<MaEinstellung> getSicherungen() {

		var v = new ArrayList<MaEinstellung>
		var MaEinstellung e
		var String str
		var String wert
		var String[] array
		var ende = false
		for (var i = 1; !ende; i++) {
			str = '''Sicherung_«i»'''
			wert = Jhh6::getEinstellungen.holeResourceDaten(str)
			if (Global::nes(wert)) {
				ende = true
			} else {
				e = new MaEinstellung
				e.setMandantNr(i)
				array = Sicherung::splitQuelleZiel(wert, false)
				e.setSchluessel(array.get(0))
				e.setWert(array.get(1))
				v.add(e)
			}
		}
		return v
	}

	def private void speichern() {

		var i = 0
		for (VerzeichnisseData e : verzeichnisse.items) {
			i++
			Jhh6::getEinstellungen.setzeResourceDaten('''Sicherung_«i»''', '''«e.data.schluessel»<«e.data.wert»''')
		}
		Jhh6::getEinstellungen.setzeResourceDaten('''Sicherung_«(i + 1)»''', "")
	}

	def private void onSicherungTimer(boolean diffSicherung, boolean zurueck) {

		val MaEinstellung k = getValue(verzeichnisse, true)
		val Task<Void> task = ([|
			status.setLength(0)
			abbruch.setLength(0)
			kopierFehler.clear
			onSicherungStatus
			var sicherung0 = '''«k.schluessel»<«k.wert»'''
			var String[] sicherungen = #[sicherung0] as String[]
			onSicherungStatusTimer
			try {
				var sicherung = new Sicherung(diffZeit, kopierFehler, status, maxFehler, abbruch, diffSicherung,
					zurueck, LocalDateTime::now)
				status.append(Meldungen::M1031)
				for (var i = 0; sicherungen !== null && i < sicherungen.length; i++) {
					sicherung.machSicherungVorbereitung({
						val _rdIndx_sicherungen = i
						sicherungen.get(_rdIndx_sicherungen)
					})
				}
				status.setLength(0)
				status.append(Meldungen::M1032)
				sicherung.machSicherung
			} catch (Exception ex) {
				status.setLength(0)
				status.append(Meldungen::M1033(ex.message))
			} finally {
				abbruch.append("Ende")
			}
			null as Void
		] as Task<Void>)
		var th = new Thread(task)
		th.setDaemon(true)
		th.start
	}

	def private void onSicherungStatus() {

		statusText.setText(status.toString)
		// view.setKopierFehler(model.daten.kopierFehler)
		if (abbruch.length > 0) {
			throw new RuntimeException("")
		}
	}

	def private void onSicherungStatusTimer() {

		var Task<Void> task = ([|
			try {
				while (true) {
					onSicherungStatus
					Thread::sleep(1000)
				}
			} catch (Exception ex) {
				Global::machNichts
			}
			return null as Void
		] as Task<Void>)
		var th = new Thread(task)
		th.setDaemon(true)
		th.start
	}

	def private void onMandantKopierenTimer(boolean vonRep) {

		if (Werkzeug::showYesNoQuestion(Meldungen::M1010) === 0) {
			return;
		}
		var Task<Void> task = ([|
			status.setLength(0)
			abbruch.setLength(0)
			kopierFehler.clear
			onSicherungStatus
			onSicherungStatusTimer
			try {
				// var r = FactoryService::replikationService.copyMandant(serviceDaten, vonRep, Global.strInt(mandant.text), status, abbruch)
				// r.throwErstenFehler
			} catch (Exception ex) {
				status.setLength(0)
				status.append(Meldungen::M1033(ex.message))
			} finally {
				abbruch.append("Ende")
			}
			return null as Void
		] as Task<Void>)
		var th = new Thread(task)
		th.setDaemon(true)
		th.start
	}

	/** 
	 * Event für MandantKopieren.
	 */
	@FXML def void onMandantKopieren() {
		onMandantKopierenTimer(false)
	}

	/** 
	 * Event für MandantRepKopieren.
	 */
	@FXML def void onMandantRepKopieren() {
		onMandantKopierenTimer(true)
	}
}
