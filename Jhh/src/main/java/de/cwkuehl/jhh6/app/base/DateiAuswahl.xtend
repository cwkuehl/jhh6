package de.cwkuehl.jhh6.app.base

import java.io.File
import javax.swing.JFileChooser
import javax.swing.filechooser.FileFilter
import javax.swing.filechooser.FileView
import de.cwkuehl.jhh6.api.global.Global
import de.cwkuehl.jhh6.app.Jhh6

class DateiAuswahl {

	def static String auswaehlen(boolean tempVerz, String dateiname, String ok, String endung, String endungLang) {

		var String pfad = ""
		var File theFile = null
		if (tempVerz) {
			pfad += Jhh6.getEinstellungen().getTempVerzeichnis()
		}
		if (!Global.nes(pfad) && !pfad.endsWith(File.separator)) {
			pfad += File.separator
		}
		if (!Global.nes(dateiname)) {
			pfad += dateiname
		}
		theFile = new File(pfad)
		var JFileChooser chooser = new JFileChooser()
		chooser.setApproveButtonText(ok)
		chooser.setSelectedFile(theFile)
		var FileFilter filter = new FileFilter() {
			/** 
			 * Whether the given file is accepted by this filter. 
			 */
			override boolean accept(File f) {
				if (f !== null) {
					if (f.isDirectory()) {
						return true
					}
					var String filename = f.getName()
					var String ^extension = null
					var int i = filename.lastIndexOf(Character.valueOf('.').charValue)
					if (i > 0 && i < filename.length() - 1) {
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
				return endungLang
			}
		}
		chooser.setFileFilter(filter)
		var int retval = chooser.showDialog(null, null)
		if (retval === JFileChooser.APPROVE_OPTION) {
			theFile = chooser.getSelectedFile()
			if (theFile !== null) {
				if (tempVerz) {
					Jhh6.getEinstellungen().setTempVerzeichnis(theFile.getParent())
				}
				return theFile.getPath()
			}
		}
		return null
	}
}
