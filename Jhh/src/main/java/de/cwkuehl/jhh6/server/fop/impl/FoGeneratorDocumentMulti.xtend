package de.cwkuehl.jhh6.server.fop.impl

import java.io.IOException
import java.util.ArrayList
import java.util.List
import javax.xml.transform.Source

/** 
 * Diese Klasse generiert ein Mehrfach-Dokument.
 */
class FoGeneratorDocumentMulti {

	// private static Log log = LogFactory.getLog(FoGeneratorDocumentMulti.class);
	int anzahl = 0
	List<FoGeneratorDocument> liste = null
	FoGeneratorDocumentStream fds = null

	/** 
	 * Standard-Konstruktor.
	 */
	new() {
		liste = new ArrayList<FoGeneratorDocument>
		fds = new FoGeneratorDocumentStream
	}

	/** 
	 * Das Löschen des Streams sollte zu Beginn eines Dokuments gemacht werden.
	 */
	def void clear() {

		liste.clear
		if (!fds.isEmpty) {
			fds.clear
		}
	}

	/** 
	 * Hinzufügen eines FO-Dokuments. Dies muss vor der Generierung erfolgen.
	 * @param doc FO-Dokument.
	 * @param resetPageNumber Soll die Seitennumerierung bei 1 anfangen?
	 */
	def void add(FoGeneratorDocument doc, boolean resetPageNumber) {

		if (!fds.isEmpty) {
			fds.clear
		}
		doc.setMultiName(Integer.toString({
			anzahl = anzahl + 1
		}))
		doc.setResetPageNumber(resetPageNumber)
		liste.add(doc)
	}

	def private void generate() {

		try {
			if (fds.isEmpty) {
				var FoGeneratorDocument doc1 = null
				if (!liste.isEmpty) {
					doc1 = liste.get(0)
				}
				// Anfang: bis <fo:layout-master-set>
				if (doc1 !== null) {
					fds.append(doc1.getFragment(0))
				}
				// fo:simple-page-master oder fo:page-sequence-master bis </fo:page-sequence-master>
				for (FoGeneratorDocument doc : liste) {
					fds.append(doc.getFragment(1))
				}
				// Mitte: bis <fo:page-sequence
				if (doc1 !== null) {
					fds.append(doc1.getFragment(2))
				}
				// fo:page-sequence bis </fo:page-sequence>
				for (FoGeneratorDocument doc : liste) {
					fds.append(doc.getFragment(3))
				}
				// Ende: bis zum Ende
				if (doc1 !== null) {
					fds.append(doc1.getFragment(4))
				}
			}
		} catch (IOException e) {
			throw new JhhFopException(e) // log.error("", e);
		}

	}

	/** 
	 * Schreibt das XML-Dokument als Datei.
	 * @param dateiname
	 * @throws JhhFopException
	 */
	def void writeDocument(String dateiname) throws JhhFopException {
		generate
		fds.writeDocument(dateiname)
	}

	/** 
	 * Liefert StreamSource.
	 * @return StreamSource.
	 */
	def Source getSource() {
		generate
		return fds.getSource
	}

	/** 
	 * Liefert SHA-1-Hash des momentanen FO-Dokuments.
	 * @return SHA-1-Hash des momentanen FO-Dokuments.
	 */
	def byte[] getSha1Hash() {
		generate
		return fds.getSha1Hash
	}

	/** 
	 * Liefert die Anzahl der enthaltenen Dokumente.
	 * @return Anzahl der enthaltenen Dokumente.
	 */
	def int getAnzahl() {
		return anzahl
	}
}
