package de.cwkuehl.jhh6.app.base

import java.io.File
import javax.swing.JFileChooser
import javax.swing.filechooser.FileFilter
import javax.swing.filechooser.FileView
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.app.Jhh6

class DateiAuswahl {

	def static String auswaehlen(boolean tempVerz, String dateiname, String ok, String endung, String endungLang) {

		var pfad = ""
		var File theFile
		if (tempVerz) {
			pfad += Jhh6::einstellungen.tempVerzeichnis
		}
		if (!Global.nes(pfad) && !pfad.endsWith(File.separator)) {
			pfad += File.separator
		}
		if (!Global.nes(dateiname)) {
			pfad += Global::g0(dateiname)
		}
		theFile = new File(pfad)
		var chooser = new JFileChooser
		chooser.setApproveButtonText(Global::g(ok))
		chooser.setSelectedFile(theFile)
		var filter = new FileFilter {

			/** Whether the given file is accepted by this filter. */
			override boolean accept(File f) {

				if (f !== null) {
					if (f.isDirectory) {
						return true
					}
					var filename = f.name
					var String ^extension
					var i = filename.lastIndexOf(Character.valueOf('.').charValue)
					if (i > 0 && i < filename.length - 1) {
						^extension = filename.substring(i + 1)
					}
					if (^extension !== null && (^extension.equalsIgnoreCase(endung))) {
						return true
					}
				}
				return false
			}

			/** 
			 * The description of this filter. For example: "JPG and GIF Images"
			 * @see FileView#getName
			 */
			override String getDescription() {
				return Global::g0(endungLang)
			}
		}
		chooser.setFileFilter(filter)
		var retval = chooser.showDialog(null, null)
		if (retval === JFileChooser.APPROVE_OPTION) {
			theFile = chooser.selectedFile
			if (theFile !== null) {
				if (tempVerz) {
					Jhh6::einstellungen.setTempVerzeichnis(theFile.parent)
				}
				return theFile.path
			}
		}
		return null
	}
}
