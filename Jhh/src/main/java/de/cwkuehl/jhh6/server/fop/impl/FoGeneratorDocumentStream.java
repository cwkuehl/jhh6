package de.cwkuehl.jhh6.server.fop.impl;

import java.io.BufferedOutputStream;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.UnsupportedEncodingException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

import javax.xml.transform.Source;
import javax.xml.transform.stream.StreamSource;

/**
 * Diese Klasse speichert ein FO-Dokument als Ganzes (Einzel-Dokument) oder in Fragmenten (Mehrfach-Dokument).
 */
public class FoGeneratorDocumentStream {

	//private static Log log = LogFactory.getLog(FoGeneratorDocumentStream.class);
	private static String charsetName = "UTF-8";
	private static String CR = "\r\n";
	private ByteArrayOutputStream bs[] = null;
	private OutputStreamWriter osw[] = null;
	private StringBuffer buffer = null;
	private int anzahl = 1;
	private int aktuell = 0;

	private boolean fragmente = false;

	/**
	 * Standard-Konstruktor.
	 */
	public FoGeneratorDocumentStream() {

		fragmente = false;
		clear();
	}

	/**
	 * Das Löschen des Streams sollte zu Beginn eines Dokuments gemacht werden.
	 */
	public void clear() {

		try {
			if (fragmente) {
				anzahl = 5;
			} else {
				anzahl = 1;
			}
			aktuell = 0;
			if (buffer == null) {
				buffer = new StringBuffer();
			} else {
				buffer.setLength(0);
			}
			if (bs == null) {
				bs = new ByteArrayOutputStream[anzahl];
			}
			if (osw == null) {
				osw = new OutputStreamWriter[anzahl];
			}
			for (int i = 0; i < anzahl; i++) {
				if (osw[i] != null) {
					osw[i].flush();
				}
				if (osw[i] == null || bs[i] == null || bs[i].size() > 0) {
					bs[i] = new ByteArrayOutputStream();
					osw[i] = new OutputStreamWriter(bs[i], charsetName);
				}
			}
		} catch (IOException e) {
			//log.error("", e);
			throw new JhhFopException(e);
		}
	}

	private String grenze0 = "<fo:layout-master-set>" + CR; // vorheriges
	private String grenze1 = "</fo:layout-master-set>" + CR; // naechstes
	private String grenze2 = "<fo:page-sequence"; // naechstes
	private String grenze3 = "</fo:page-sequence>" + CR; // vorheriges

	private boolean isGleich(String str) {
		return str.equals(buffer.toString());
	}

	private boolean isFalsch(String str) {

		String b = buffer.toString();
		if (b.length() <= str.length()) {
			return !b.equals(str.substring(0, b.length()));
		}
		return true;
	}

	/**
	 * Anhängen eines Strings an den Stream.
	 * @param str Anzuhängender String.
	 * @return this.
	 * @throws IOException
	 */
	public FoGeneratorDocumentStream append(String str) throws IOException {

		if (fragmente) {
			boolean flush = false;
			boolean naechstes = false;
			boolean vorheriges = false;
			buffer.append(str);
			if (aktuell == 0) {
				if (isGleich(grenze0)) {
					vorheriges = true;
					flush = true;
				} else if (isFalsch(grenze0)) {
					flush = true;
				}
			} else if (aktuell == 1) {
				if (isGleich(grenze1)) {
					naechstes = true;
					flush = true;
				} else if (isFalsch(grenze1)) {
					flush = true;
				}
			} else if (aktuell == 2) {
				if (isGleich(grenze2)) {
					naechstes = true;
					flush = true;
				} else if (isFalsch(grenze2)) {
					flush = true;
				}
			} else if (aktuell == 3) {
				if (isGleich(grenze3)) {
					vorheriges = true;
					flush = true;
				} else if (isFalsch(grenze3)) {
					flush = true;
				}
			}
			if (flush && buffer.length() > 0) {
				if (naechstes) {
					aktuell++;
				}
				osw[aktuell].append(buffer.toString());
				if (vorheriges) {
					aktuell++;
				}
				buffer.setLength(0);
			}
		} else {
			osw[aktuell].append(str);
		}
		return this;
	}

	/**
	 * Anhängen eines Zeilenumbruchs an den Stream.
	 * @return this.
	 * @throws IOException
	 */
	public FoGeneratorDocumentStream appendCrLf() throws IOException {

		return append(CR);
	}

	/**
	 * Anhängen des Zeichensatz-Namens an den Stream.
	 * @return this.
	 * @throws IOException
	 */
	public FoGeneratorDocumentStream appendCharsetName() throws IOException {

		return append(charsetName);
	}

	/**
	 * @return Speichert der Stream Fragmente.
	 */
	public boolean isFragmente() {
		return fragmente;
	}

	/**
	 * Die zugrunde liegendenden Stream werden geflutet.
	 */
	private void flush() {

		try {
			if (buffer.length() > 0) {
				osw[aktuell].append(buffer.toString());
				buffer.setLength(0);
			}
			for (int i = 0; i < anzahl; i++) {
				osw[i].flush();
			}
		} catch (IOException e) {
			//log.error("", e);
			throw new JhhFopException(e);
		}
	}

	/**
	 * Liefert StreamSource.
	 * @return StreamSource.
	 */
	public Source getSource() {

		flush();
		return new StreamSource(new ByteArrayInputStream(bs[aktuell].toByteArray()));
	}

	/**
	 * Schreibt das XML-Dokument als Datei.
	 * 
	 * @param dateiname
	 */
	public void writeDocument(String dateiname) {

		OutputStream out = null;
		try {
			flush();
			out = new BufferedOutputStream(new FileOutputStream(new File(dateiname)));
			bs[aktuell].writeTo(out);
		} catch (IOException e) {
			//log.error("", e);
			throw new JhhFopException(e);
		} finally {
			if (out != null) {
				try {
					out.close();
				} catch (IOException e) {
					//log.error("", e);
					throw new JhhFopException(e);
				}
			}
		}
	}

	/**
	 * Liefert SHA-1-Hash des momentanen FO-Dokuments.
	 * @return SHA-1-Hash des momentanen FO-Dokuments.
	 */
	public byte[] getSha1Hash() {

		flush();
		try {
			MessageDigest md = MessageDigest.getInstance("SHA-1");
			md.update(bs[aktuell].toByteArray());
			byte[] digest = md.digest();
			return digest;
		} catch (NoSuchAlgorithmException e) {
			return null;
		}
	}

	/**
	 * Liefert Zeilenumbruch als String.
	 * @return Zeilenumbruch als String.
	 */
	public static String getCR() {
		return CR;
	}

	/**
	 * Setzt den Stream in den Einzel- (false) oder Mehrfach-Dokument-Modus (true).
	 * @param fragmente Ist Mehrfach-Dokument-Modus?
	 */
	public void setFragmente(boolean fragmente) {

		if (this.fragmente != fragmente) {
			this.fragmente = fragmente;
			bs = null;
			osw = null;
			clear();
		}
	}

	/**
	 * Ist der Stream leer?
	 * @return true, wenn Stream leer ist; sonst false.
	 */
	public boolean isEmpty() {

		flush();
		for (int i = 0; i < anzahl; i++) {
			if (bs[i].size() > 0) {
				return false;
			}
		}
		return true;
	}

	/**
	 * Inhalt des Stream-Fragments als String.
	 * @param nr Nummer des Fragments beginnend mit 0.
	 * @return Inhalt des Stream-Fragments als String.
	 */
	public String getFragment(int nr) {

		flush();
		if (nr < 0 || nr > anzahl - 1) {
			return "";
		}
		String str = "";
		try {
			str = new String(bs[nr].toByteArray(), charsetName);
		} catch (UnsupportedEncodingException e) {
			//log.error("getFragment", e);
			throw new JhhFopException(e);
		}
		return str;
	}

}
