package de.cwkuehl.jhh6.app.base

import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.app.Jhh6
import java.awt.Desktop
import java.io.BufferedReader
import java.io.BufferedWriter
import java.io.File
import java.io.FileOutputStream
import java.io.FileReader
import java.io.FileWriter
import java.io.Writer
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
import javafx.stage.Screen
import javafx.stage.Stage
import org.apache.log4j.Logger
import org.eclipse.xtend.lib.annotations.Accessors

class Werkzeug {

	var static log = Logger.getLogger(typeof(Werkzeug))

	/**
	 * Liefert einen String mit Information über das Programm.
	 * @return String.
	 */
	def public static String getInfoListe() {

		var sb = new StringBuffer
		sb.append("<html>")
		sb.append("<table>")
		sb.append("<tr><td>").append("Programm-Version:").append("</td><td>").append("5.1 vom 01.07.2016").append(
			"</td></tr>")
		sb.append("<tr><td>").append("Erstellung am:").append("</td><td>").append(
			Global.getManifestProperty(typeof(Werkzeug), "/META-INF/MANIFEST.MF", "Built-Time")).append("</td></tr>")
		sb.append("<tr><td>").append("Betriebssystem:").append("</td><td>").append(System.getProperty("os.name")).
			append(" (").append(System.getProperty("os.version")).append(")").append("</td></tr>")
		sb.append("<tr><td>").append("Java-Version:").append("</td><td>").append(System.getProperty("java.vm.version")).
			append("</td></tr>")
		sb.append("<tr><td>").append("Java-Verzeichnis:").append("</td><td>").append(System.getProperty("java.home")).
			append("</td></tr>")
		sb.append("<tr><td>").append("Benutzer-Verz.:").append("</td><td>").append(System.getProperty("user.dir")).
			append("</td></tr>")
		val props = new Properties()
		val input = typeof(Werkzeug).getClassLoader().getResourceAsStream("ServerConfig.properties")
		props.load(input)
		var jdbcUrl = props.getProperty("DB_DRIVER_CONNECT")
		if (!Global.nes(jdbcUrl)) {
			sb.append("<tr><td>").append("Datenbank:").append("</td><td>").append(jdbcUrl).append("</td></tr>")
		}
		if (Global.isWebStart) {
			sb.append("<tr><td>").append("JNLP-Verzeichnis:").append("</td><td>").append(
				System.getProperty("jnlpx.home")).append("</td></tr>")
		}
		sb.append("</table>")
		sb.append("</html>")
		return sb.toString
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
			alert.setHeaderText("Hinweis")
		} else {
			alert.setHeaderText("Fehler")
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
		var expContent = new GridPane()
		expContent.setMaxWidth(Double.MAX_VALUE)
		expContent.add(label, 0, 0)
		expContent.add(textArea, 0, 1)
		// alert.getDialogPane().setExpandableContent(expContent)
		alert.getDialogPane().setContent(expContent)
		var r = alert.showAndWait
		if (r.present && r.get() == ButtonType.OK) {
			return 1
		}
		return 0
	}

	def public static String showInputDialog(String msg, String init) {

		var dialog = new TextInputDialog(init)
		dialog.setTitle("Eingabe")
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

		var g = Jhh6.getEinstellungen().getDialogGroesse(key)
		if (g.leer) {
			var b = Screen.getPrimary().getVisualBounds()
			if (key === null) {
				g.setX(b.getWidth() / 8)
				g.setY(b.getHeight() / 8)
				g.setWidth(b.getWidth() * 3 / 4)
				g.setHeight(b.getHeight() * 3 / 4)
			} else {
				g.setX(b.getWidth() / 4)
				g.setY(b.getHeight() / 4)
				g.setWidth(b.getWidth() * 2 / 4)
				g.setHeight(b.getHeight() * 2 / 4)
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
		Jhh6.einstellungen.setDialogGroesse(key, g)
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
				f.close()
			}
		}
	}

	def public static void speicherReport(byte[] bytes, String name, boolean datumZufall) {

		if (bytes !== null && bytes.length > 0) {
			var pfad = Jhh6.einstellungen.tempVerzeichnis
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
				f.close()
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
				if (Desktop.isDesktopSupported()) {
					var t = new Thread [
						Desktop.getDesktop().open(new File(dateiname))
					]
					t.start
				} else {
					throw new Exception("Awt-Desktop is not supported.")
				}
			}
			rc = true
		} catch (Exception ex) {
			throw new RuntimeException(ex)
		}
		return rc
	}

	def public static void speicherDateiOeffnen(List<String> zeilen, String pfad, String datei, boolean anhaengen) {

		var String dateiname = Werkzeug.pfadDatei(pfad, datei)
		speicherDatei(zeilen, dateiname, anhaengen)
		oeffneTextEditor(dateiname)
	}

	def public static void speicherDateiOeffnen(byte[] bytes, String pfad, String datei, boolean anhaengen) {

		var String dateiname = Werkzeug.pfadDatei(pfad, datei)
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
		return f.getPath()
	}

	def public static List<String> leseDatei(String datei) {

		var BufferedReader f = null
		var zeilen = new ArrayList<String>
		try {
			f = new BufferedReader(new FileReader(datei))
			var String zeile = null
			while ((zeile = f.readLine()) !== null) {
				zeilen.add(zeile)
			}
		} finally {
			if (f !== null) {
				f.close()
			}
		}
		return zeilen
	}
}

/**
 * Klasse zur Weitergabe von Fenstergrößen.
 */
@Accessors
public class Groesse {
	/** Breite. */
	double width = 0
	/** Höhe. */
	double height = 0
	/** x-Position. */
	double x = 0
	/** y-Position. */
	double y = 0

	def boolean leer() {
		return width == 0 && height == 0 && x == 0 && y == 0
	}
}
