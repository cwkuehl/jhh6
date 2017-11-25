package de.cwkuehl.jhh6.app

import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.message.MeldungException
import de.cwkuehl.jhh6.api.service.ServiceDaten
import de.cwkuehl.jhh6.api.service.ServiceErgebnis
import de.cwkuehl.jhh6.app.base.Einstellungen
import de.cwkuehl.jhh6.app.base.Werkzeug
import de.cwkuehl.jhh6.app.controller.Jhh6Controller
import java.io.IOException
import java.lang.reflect.InvocationTargetException
import java.net.URL
import javafx.application.Application
import javafx.application.Platform
import javafx.fxml.FXMLLoader
import javafx.scene.Parent
import javafx.scene.Scene
import javafx.scene.image.Image
import javafx.stage.Stage
import org.slf4j.Logger
import org.slf4j.LoggerFactory

class Jhh6 extends Application {

	static ServiceDaten serviceDaten = new ServiceDaten(0, "Benutzer-ID")
	static Einstellungen einstellungen = null
	static Stage stage = null
	static Jhh6Controller controller = null
	protected static Logger log = LoggerFactory::getLogger(typeof(Jhh6))

	// static final Void static_initializer = {
	// {
	// log.error("Static-Start")
	// null
	// }
	// }
	def static void main(String[] args) {
		// Locale.setDefault(Locale.ENGLISH);
		if (Global::isWebStart()) {
			if (args !== null) {
				log.error('''JHH6-Argumente: «String::join(" ", args)»'''.toString)
			}
		}
		launch(args)
	}

	override void start(Stage stage) throws IOException {
		Thread::currentThread().setUncaughtExceptionHandler([ thread, t0 |
			{
				var Throwable t = t0
				if (t instanceof RuntimeException) {
					var RuntimeException ex = (t as RuntimeException)
					if (ex.getCause() !== null) {
						t = ex.getCause()
						if (t instanceof InvocationTargetException) {
							var InvocationTargetException ex2 = (t as InvocationTargetException)
							if (ex2.getTargetException() !== null) {
								t = ex2.getTargetException()
							}
						}
					}
				}
				if (!(t instanceof MeldungException)) {
					log.error("UncaughtExceptionHandler", t)
				}
				var String s = Global::getExceptionText(t)
				setLeftStatus(s)
			}
		])
		var ClassLoader classLoader = Thread::currentThread().getContextClassLoader()
		var URL fxmlURL = classLoader.getResource("dialog/Jhh6.fxml")
		var FXMLLoader loader = new FXMLLoader(fxmlURL, Werkzeug::bundle)
		var Parent p = loader.load
		controller = loader.getController()
		controller.init(stage, null)
		var Scene scene = new Scene(p)
		stage.setScene(scene)
		stage.setTitle(getTitel())
		if (Global::istLinux) {
			// Absturz verhindern: https://bugs.openjdk.java.net/browse/JDK-8141687
			stage.getIcons().add(new Image(classLoader.getResourceAsStream("WKHH.gif")))
		}
		stage.show()
		if (Jhh6::stage === null) {
			Jhh6::stage = stage
		}
		var g = Werkzeug.getDialogGroesse("Rahmen")
		stage.setX(g.getX())
		stage.setY(g.getY())
		stage.setWidth(g.getWidth())
		stage.setHeight(g.getHeight())
		stage.setOnCloseRequest([ event |
			{
				Platform::exit() // Anwendung beenden
			}
		])
	}

	override void stop() {

		controller.closeTabs
		Werkzeug.setDialogGroesse("Rahmen", stage)
		getEinstellungen().save
	}

	def static Einstellungen getEinstellungen() {

		if (einstellungen === null) {
			einstellungen = new Einstellungen
		}
		return einstellungen
	}

	def static ServiceDaten getServiceDaten() {
		return new ServiceDaten(serviceDaten.getMandantNr(), serviceDaten.getBenutzerId())
	}

	def static void setServiceDaten(ServiceDaten daten) {

		if (daten === null) {
			serviceDaten = new ServiceDaten(0, "Benutzer-ID")
		} else {
			serviceDaten = new ServiceDaten(daten.getMandantNr(), daten.getBenutzerId())
		}
	}

	def static String getTitelKurz() {

		var str = new StringBuffer
		str.append("JHH6 ")
		str.append(getEinstellungen().getAnwendungsTitel(serviceDaten.mandantNr))
		str.append(" W. Kuehl")
		return str.toString()
	}

	def private static String getTitel() {

		var str = new StringBuffer
		if (getEinstellungen().isTest) {
			str.append("Test-")
		}
		str.append("JHH6 ")
		str.append(getEinstellungen().getAnwendungsTitel(serviceDaten.mandantNr))
		str.append(" W. Kuehl")
		var mandantNr = getServiceDaten().getMandantNr()
		if (mandantNr <= 0) {
			str.append(" (nicht angemeldet)")
		} else if (mandantNr !== 1) {
			str.append(" (Mandant ").append(mandantNr).append(")")
		}
		return str.toString
	}

	def static void aktualisiereTitel() {

		if (stage !== null) {
			stage.setTitle(getTitel())
		}
	}

	/** 
	 * Anzeige einer Meldung in einer Messagebox und in der Statuszeile. 
	 */
	def static void setLeftStatus(String str) {

		if (!Global::nes(str)) {
			Platform.runLater([
				Werkzeug.showError(str)
			])
		}
		setLeftStatus2(str)
	}

	/** 
	 * Anzeige einer Meldung in der Statuszeile. 
	 */
	def static void setLeftStatus2(String str) {

		if (controller !== null) {
			Platform.runLater([
				controller.setLeftStatus(str)
			])
		}
	}

	def static ServiceErgebnis<Void> rollback() {
		// var ServiceErgebnis<Void> r = FactoryService.getReplikationService().rollback(getServiceDaten())
		// if (r.ok()) {
		// getEinstellungen().refreshMandant()
		// }
		// return r
		return null
	}

	def static ServiceErgebnis<Void> redo() {
		// var ServiceErgebnis<Void> r = FactoryService.getReplikationService().redo(getServiceDaten())
		// if (r.ok()) {
		// getEinstellungen().refreshMandant()
		// }
		// return r
		return null
	}
}
