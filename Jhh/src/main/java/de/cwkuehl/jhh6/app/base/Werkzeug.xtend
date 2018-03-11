package de.cwkuehl.jhh6.app.base

import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.api.message.Meldungen
import de.cwkuehl.jhh6.api.service.ServiceDaten
import de.cwkuehl.jhh6.app.Jhh6
import java.awt.Desktop
import java.io.BufferedInputStream
import java.io.BufferedReader
import java.io.BufferedWriter
import java.io.File
import java.io.FileOutputStream
import java.io.FileReader
import java.io.FileWriter
import java.io.Writer
import java.net.URL
import java.util.ArrayList
import java.util.List
import java.util.Properties
import javafx.scene.control.Alert
import javafx.scene.control.Alert.AlertType
import javafx.scene.control.ButtonType
import javafx.scene.control.Label
import javafx.scene.control.TextArea
import javafx.scene.control.TextInputDialog
import javafx.scene.layout.GridPane
import javafx.scene.layout.Priority
import javafx.scene.web.WebEngine
import javafx.stage.Screen
import javafx.stage.Stage
import org.apache.log4j.Logger

import static de.cwkuehl.jhh6.api.global.Global.g
import static de.cwkuehl.jhh6.api.global.Global.hasg

class Werkzeug {

	var static log = Logger.getLogger(typeof(Werkzeug))

	/**
	 * Liefert einen HTML-String mit Informationen über das Programm.
	 * @return String.
	 */
	def public static String getProgramInfo() {

		var sb = new StringBuffer
		sb.append("<html>")
		sb.append("<table>")
		sb.append("<tr><td>").append(g("AG000.version")).append("</td><td>").append("6.0 (01.01.2018)").append(
			"</td></tr>")
		sb.append("<tr><td>").append(g("AG000.creation")).append("</td><td>").append(
			Global.getManifestProperty(typeof(Werkzeug), "/META-INF/MANIFEST.MF", "Built-Time")).append("</td></tr>")
		sb.append("<tr><td>").append(g("AG000.os")).append("</td><td>").append(System.getProperty("os.name")).
			append(" (").append(System.getProperty("os.version")).append(")").append("</td></tr>")
		sb.append("<tr><td>").append(g("AG000.java")).append("</td><td>").append(System.getProperty("java.vm.version")).
			append("</td></tr>")
		sb.append("<tr><td>").append(g("AG000.javahome")).append("</td><td>").append(System.getProperty("java.home")).
			append("</td></tr>")
		sb.append("<tr><td>").append(g("AG000.userhome")).append("</td><td>").append(System.getProperty("user.dir")).
			append("</td></tr>")
		val props = new Properties
		val input = typeof(Werkzeug).classLoader.getResourceAsStream("ServerConfig.properties")
		props.load(input)
		var jdbcUrl = props.getProperty("DB_DRIVER_CONNECT")
		if (!Global.nes(jdbcUrl)) {
			sb.append("<tr><td>").append(g("AG000.db")).append("</td><td>").append(jdbcUrl).append("</td></tr>")
		}
		if (Global.isWebStart) {
			sb.append("<tr><td>").append(g("AG000.jnlphome")).append("</td><td>").append(
				System.getProperty("jnlpx.home")).append("</td></tr>")
		}
		sb.append("</table>")
		sb.append("</html>")
		return sb.toString
	}

	/**
	 * Liefert einen HTML-String mit Anmelde-Status.
	 * @parm daten Service-Daten für Datenbank-Zugriff.
	 * @return String.
	 */
	def public static String getLoginInfo(ServiceDaten daten) {

		var sb = new StringBuffer
		sb.append("<html>")
		if (daten.mandantNr <= -10) {
			sb.append(g("AG000.init"))
		} else {
			sb.append("<table>")
			sb.append("<tr><td>").append(g("AG000.client")).append("</td><td>").append(daten.mandantNr).append(
				"</td></tr>")
			sb.append("<tr><td>").append(g("AG000.user")).append("</td><td>").append(daten.benutzerId).append(
				"</td></tr>")
			sb.append("</table>")
		}
		sb.append("</html>")
		return sb.toString
	}

	/**
	 * Liefert einen HTML-String mit Anmelde-Status.
	 * @return String.
	 */
	def public static String getLicenseInfo() {

		var sb = new StringBuffer
		sb.append("<html>")
		sb.append("<h1>").append(g("AG000.header")).append("</h1>")
		sb.append("<p>").append(g("AG000.mit")).append("</p>")
		sb.append("<p>").append(g("AG000.libs")).append("</p>")
		sb.append("<table>")
		var ende = false
		var i = 1
		do {
			var key = '''AG000.lib«i»'''
			if (hasg(key)) {
				sb.append("<tr><td>").append(g(key)).append("</td><td>").append(g(key + ".1")).append("</td><td>").
					append(g(key + ".2")).append("</td></tr>")
				i++
			} else
				ende = true
		} while (!ende)
		sb.append("</table>")
		sb.append("<p>").append(g("AG000.icons")).append("</p>")
		sb.append("<table>")
		ende = false
		i = 1
		do {
			var key = '''AG000.icon«i»'''
			if (hasg(key)) {
				sb.append("<tr><td>").append(g(key)).append("</td><td>").append(g(key + ".1")).append("</td></tr>")
				i++
			} else
				ende = true
		} while (!ende)
		sb.append("</table>")
		sb.append("</html>")
		return sb.toString
	}

	/** Is an update available? */
	def public static boolean isUpdateAvailable() {

		var BufferedInputStream in = null
		try {
			in = new BufferedInputStream(
				new URL("http://cwkuehl.de/wp-content/uploads/2018/02/update.txt").openStream)
			val data = newByteArrayOfSize(19)
			if (in.read(data, 0, data.length) >= data.length) {
				val sbt = Global.getManifestProperty(typeof(Werkzeug), "/META-INF/MANIFEST.MF", "Built-Time")
				val bt = Global.strdat(sbt)
				val up = Global.strdat(new String(data))
				if (bt !== null && up !== null && bt.isBefore(up))
					return true
			}
		} catch (Throwable t) {
			Global.machNichts
		} finally {
			if (in !== null) {
				in.close
			}
		}
		return false
	}

	/**
	 * Setzt die Hilfe-Datei in eine WebEngine.
	 * @param Betroffene WebEngine, die die Hilfe anzeigen soll.
	 */
	def public static void setHelp(WebEngine we) {

		var html = '''/«g("parm.AG_HILFE_DATEI.value")»''' // "/Jhh-Hilfe.html"
		var url = Werkzeug.getClass.getResource(html)
		if (url === null) {
			html = Jhh6::einstellungen.hilfeDatei
			url = Werkzeug.getClass.getResource(html)
			if (url === null)
				url = new File(html).toURI.toURL
		}
		if (url === null) {
			we.loadContent('''<html>«Meldungen::M3000(html)»</html>''')
		} else {
			we.load(url.toExternalForm)
		}
	}

	def public static void showError(String str) {
		showAlert(AlertType.ERROR, str)
	}

	def public static void showInfo(String str) {
		showAlert(AlertType.INFORMATION, str)
	}

	def public static void showException(Throwable t) {

		if (t !== null) {
			log.error("JHH6", t)
			showAlert(AlertType.ERROR, t.message)
		}
	}

	def private static int showAlert(AlertType typ, String str) {

		var alert = new Alert(typ)
		alert.setTitle(Jhh6.titelKurz)
		if (typ == AlertType.INFORMATION) {
			alert.setHeaderText(g("alert.info"))
		} else if (typ == AlertType.CONFIRMATION) {
			alert.setHeaderText(g("alert.confirm"))
		} else {
			alert.setHeaderText(g("alert.error"))
		}
		// alert.setContentText(str)
		var label = new Label("")
		var textArea = new TextArea(str)
		textArea.setEditable(false)
		textArea.setWrapText(true)
		textArea.setMaxWidth(Double.MAX_VALUE)
		textArea.setMaxHeight(Double.MAX_VALUE)
		GridPane.setVgrow(textArea, Priority.ALWAYS)
		GridPane.setHgrow(textArea, Priority.ALWAYS)
		var expContent = new GridPane
		expContent.setMaxWidth(Double.MAX_VALUE)
		expContent.add(label, 0, 0)
		expContent.add(textArea, 0, 1)
		// alert.getDialogPane.setExpandableContent(expContent)
		alert.dialogPane.setContent(expContent)
		var r = alert.showAndWait
		if (r.present && r.get == ButtonType.OK) {
			return 1
		}
		return 0
	}

	def public static String showInputDialog(String msg, String init) {

		var dialog = new TextInputDialog(init)
		dialog.setTitle(Meldungen::M1028)
		dialog.setHeaderText(msg)
		var result = dialog.showAndWait
		if (result.isPresent) {
			return result.get
		}
		return null
	}

	/** Liefert 1, wenn OK, sonst 0. */
	def public static int showYesNoQuestion(String msg) {
		return showAlert(AlertType.CONFIRMATION, msg)
	}

	def public static Groesse getDialogGroesse(String key) {

		var g = Jhh6::einstellungen.getDialogGroesse(key)
		if (g.leer) {
			var b = Screen.primary.visualBounds
			if (key === null) {
				g.x = b.width / 8
				g.y = b.height / 8
				g.width = b.width * 3 / 4
				g.height = b.height * 3 / 4
			} else {
				g.x = b.width / 4
				g.y = b.height / 4
				g.width = b.width * 2 / 4
				g.height = b.height * 2 / 4
			}
		}
		// log.info('''getDialogGroesse «key» x «g.x» y «g.y» w «g.width» h «g.height»''')
		return g
	}

	/**
	 * Speichern der Fenstergröße in den Resourcedaten.
	 * @param key Schlüssel für Resourcedaten.
	 * @param s Stage, deren Größe gespeichert werden soll.
	 */
	def public static void setDialogGroesse(String key, Stage s) {

		var g = new Groesse
		g.x = s.x
		g.y = s.y
		g.width = s.width
		g.height = s.height
		Jhh6::einstellungen.setDialogGroesse(key, g)
	// log.info('''setDialogGroesse «key» x «g.x» y «g.y» w «g.width» h «g.height»''')
	}

	def public static void speicherDatei(List<String> zeilen, String datei, boolean anhaengen) {

		if (zeilen === null) {
			return
		}

		var Writer f = null
		try {
			f = new BufferedWriter(new FileWriter(datei, anhaengen))
			for (z : zeilen) {
				if (z !== null) {
					f.write(z)
				}
			}
		} finally {
			if (f !== null) {
				f.close
			}
		}
	}

	def public static void speicherReport(byte[] bytes, String name, boolean datumZufall) {

		if (bytes !== null && bytes.length > 0) {
			var pfad = Jhh6::einstellungen.tempVerzeichnis
			try {
				var datei = Global.getDateiname(name, datumZufall, datumZufall, "pdf")
				datei = pfadDatei(pfad, datei)
				speicherDatei(bytes, datei, false)
				oeffneTextEditor(datei)
			} catch (Exception ex) {
				showException(ex)
			}
		}
	}

	def private static void speicherDatei(byte[] bytes, String datei, boolean anhaengen) {

		var FileOutputStream f = null
		try {
			f = new FileOutputStream(datei, anhaengen)
			if (bytes !== null && bytes.length > 0) {
				f.write(bytes, 0, bytes.length)
			}
		} finally {
			if (f !== null) {
				f.close
			}
		}
	}

	/**
	 * Öffnen einer Datei im Text-Editor.
	 * @param dateiname Zu öffnende Datei.
	 * @return true, wenn Aufruf in Ordnung.
	 */
	def public static boolean oeffneTextEditor(String dateiname) {

		var rc = false

		try {
			if (!Global.nes(dateiname)) {
				if (Desktop.isDesktopSupported) {
					var t = new Thread [
						Desktop.desktop.open(new File(dateiname))
					]
					t.start
				} else {
					throw new Exception(Meldungen::M1027)
				}
			}
			rc = true
		} catch (Exception ex) {
			throw new RuntimeException(ex)
		}
		return rc
	}

	def public static void speicherDateiOeffnen(List<String> zeilen, String pfad, String datei, boolean anhaengen) {

		var dateiname = Werkzeug.pfadDatei(pfad, datei)
		speicherDatei(zeilen, dateiname, anhaengen)
		oeffneTextEditor(dateiname)
	}

	def public static void speicherDateiOeffnen(byte[] bytes, String pfad, String datei, boolean anhaengen) {

		var dateiname = Werkzeug.pfadDatei(pfad, datei)
		speicherDatei(bytes, dateiname, anhaengen)
		oeffneTextEditor(dateiname)
	}

	def public static String pfadDatei(String pfad, String datei) {

		var File f = null
		if (Global.nes(pfad)) {
			f = new File(datei)
		} else {
			f = new File(new File(pfad), datei)
		}
		return f.path
	}

	def public static List<String> leseDatei(String datei) {

		var BufferedReader f = null
		var zeilen = new ArrayList<String>
		try {
			f = new BufferedReader(new FileReader(datei))
			var String zeile
			while ((zeile = f.readLine) !== null) {
				zeilen.add(zeile)
			}
		} finally {
			if (f !== null) {
				f.close
			}
		}
		return zeilen
	}
}
