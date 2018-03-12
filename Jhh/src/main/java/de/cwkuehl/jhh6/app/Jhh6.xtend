package de.cwkuehl.jhh6.app

import de.cwkuehl.jhh6.api.global.Constant
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.message.MeldungException
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.api.service.ServiceDaten
import de.cwkuehl.jhh6.api.service.ServiceErgebnis
import de.cwkuehl.jhh6.app.base.Einstellungen
import de.cwkuehl.jhh6.app.base.Werkzeug
import de.cwkuehl.jhh6.app.controller.Jhh6Controller
import de.cwkuehl.jhh6.server.FactoryService
import java.io.IOException
import java.lang.reflect.InvocationTargetException
import javafx.application.Application
import javafx.application.Platform
import javafx.fxml.FXMLLoader
import javafx.scene.Scene
import javafx.scene.image.Image
import javafx.stage.Stage
import org.slf4j.Logger
import org.slf4j.LoggerFactory

class Jhh6 extends Application {

	static ServiceDaten serviceDaten = new ServiceDaten(0, Constant.USER_ID)
	static Einstellungen einstellungen = null
	static Stage stage = null
	static Jhh6Controller controller = null
	protected static Logger log = LoggerFactory::getLogger(typeof(Jhh6))

	def static void main(String[] args) {

		// Locale.setDefault(Locale.ENGLISH);
		if (Global::isWebStart) {
			if (args !== null) {
				log.error(Meldungen::M1021(String::join(" ", args)))
			}
		}
		launch(args)
	}

	override void start(Stage stage) throws IOException {

		Thread::currentThread.setUncaughtExceptionHandler([ thread, t0 |
			{
				var Throwable t = t0
				if (t instanceof RuntimeException) {
					var ex = t
					if (ex.cause !== null) {
						t = ex.cause
						if (t instanceof InvocationTargetException) {
							var ex2 = t
							if (ex2.targetException !== null) {
								t = ex2.targetException
							}
						}
					}
				}
				if (!(t instanceof MeldungException)) {
					log.error("UncaughtExceptionHandler", t)
				}
				var s = Global::getExceptionText(t)
				setLeftStatus(s)
			}
		])
		var classLoader = Thread::currentThread.contextClassLoader
		var fxmlURL = classLoader.getResource("dialog/Jhh6.fxml")
		var loader = new FXMLLoader(fxmlURL, Global::bundle)
		var p = loader.load
		controller = loader.controller
		controller.init(stage, null)
		var scene = new Scene(p)
		stage.setScene(scene)
		stage.setTitle(getTitel)
		if (Global::istLinux) {
			// Absturz verhindern: https://bugs.openjdk.java.net/browse/JDK-8141687
			stage.icons.add(new Image(classLoader.getResourceAsStream("WKHH.gif")))
		}
		stage.show
		if (Jhh6::stage === null) {
			Jhh6::stage = stage
		}
		var g = Werkzeug.getDialogGroesse("Rahmen")
		stage.x = g.x
		stage.y = g.y
		stage.width = g.width
		stage.height = g.height
		stage.setOnCloseRequest([ event |
			Platform::exit // Anwendung beenden
		])
	}

	override void stop() {

		controller.closeTabs
		Werkzeug.setDialogGroesse("Rahmen", stage)
		getEinstellungen.save
	}

	/** Position und Größe des Hauptfenster zurücksetzen. */
	def static void reset() {

		var g = Werkzeug.getDialogGroesse(null)
		stage.x = g.x
		stage.y = g.y
		stage.width = g.width
		stage.height = g.height
	}

	def static Einstellungen getEinstellungen() {

		if (einstellungen === null) {
			einstellungen = new Einstellungen
		}
		return einstellungen
	}

	def static ServiceDaten getServiceDaten() {
		return new ServiceDaten(serviceDaten.mandantNr, serviceDaten.benutzerId)
	}

	def static void setServiceDaten(ServiceDaten daten) {

		if (daten === null) {
			serviceDaten = new ServiceDaten(0, Constant.USER_ID)
		} else {
			serviceDaten = new ServiceDaten(daten.mandantNr, daten.benutzerId)
		}
	}

	def static String getTitelKurz() {

		var str = new StringBuffer
		str.append("JHH6 ")
		str.append(getEinstellungen.getAnwendungsTitel(serviceDaten.mandantNr))
		str.append(" W. Kuehl")
		return str.toString
	}

	def private static String getTitel() {

		var str = new StringBuffer
		if (getEinstellungen.isTest) {
			str.append(Meldungen::M1024)
		}
		str.append("JHH6 ")
		str.append(getEinstellungen.getAnwendungsTitel(serviceDaten.mandantNr))
		str.append(" W. Kuehl")
		var mandantNr = getServiceDaten.mandantNr
		if (mandantNr <= 0) {
			str.append(Meldungen::M1022)
		} else if (mandantNr !== 1) {
			str.append(Meldungen::M1023(mandantNr))
		}
		return str.toString
	}

	def static void aktualisiereTitel() {

		if (stage !== null) {
			stage.setTitle(getTitel)
		}
	}

	/** 
	 * Anzeige einer Meldung in einer Messagebox und in der Statuszeile. 
	 */
	def static void setLeftStatus(String str) {

		if (!Global::nes(str)) {
			Platform.runLater([Werkzeug.showError(str)])
		}
		setLeftStatus2(str)
	}

	/** 
	 * Anzeige einer Meldung in der Statuszeile. 
	 */
	def static void setLeftStatus2(String str) {

		if (controller !== null) {
			Platform.runLater([controller.setLeftStatus(str)])
		}
	}

	def static ServiceErgebnis<Void> rollback() {

		var r = FactoryService::replikationService.rollback(getServiceDaten)
		if (r.ok) {
			getEinstellungen.refreshMandant
		}
		return r
	}

	def static ServiceErgebnis<Void> redo() {

		var r = FactoryService::replikationService.redo(getServiceDaten)
		if (r.ok) {
			getEinstellungen.refreshMandant
		}
		return r
	}
}
