package de.cwkuehl.jhh6.server.fop.impl;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;

import javax.xml.transform.Result;
import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.sax.SAXResult;

import org.apache.fop.apps.Fop;
import org.apache.fop.apps.FopFactory;
import org.apache.fop.apps.MimeConstants;


/**
 * Diese Klasse erstellt PDF- oder RTF-Dokumente aus FO-Dateien.
 */
public class JhhFop {

	private static FopFactory fopFactory = null;

	//	private static Log log = LogFactory.getLog(FopFactory.class);

	/**
	 * @param fopFactory The fopFactory to set
	 */
	public void setFopFactory(FopFactory fopFactory) {
		JhhFop.fopFactory = fopFactory;
	}

	/**
	 * @return Returns the fopFactory.
	 */
	public FopFactory getFopFactory() {
		return fopFactory;
	}

	//	/**
	//	 * @return the fopFactory
	//	 */
	//	public static FopFactory getFopFactory() {
	//
	//		if (fopFactory == null) {
	//			fopFactory = FopFactory.newInstance();
	//			DefaultConfigurationBuilder cfgBuilder = new DefaultConfigurationBuilder();
	//			InputStream inputStream = ClassLoader.class
	//					.getResourceAsStream("/fop/fop.xconf");
	//			Configuration cfg = null;
	//			try {
	//				cfg = cfgBuilder.build(inputStream);
	//				fopFactory.setUserConfig(cfg);
	//			} catch (ConfigurationException e) {
	//				log.error("", e);
	//			} catch (SAXException e) {
	//				log.error("", e);
	//			} catch (IOException e) {
	//				log.error("", e);
	//			}
	//		}
	//		return fopFactory;
	//	}

	/**
	 * Generierung einer PDF-Datei.
	 * 
	 * @param src Quell-Datei; FO-Datei, wenn xslt null.
	 * @param xslt Transform-Datei kann null sein.
	 * @param pdfDatei Ergebnis als PDF-Datei.
	 * @throws JhhFopException
	 */
	public void machPdf(Source src, Source xslt, String pdfDatei, OutputStream os) {
		machFop(src, xslt, pdfDatei, os, MimeConstants.MIME_PDF);
	}

	/**
	 * Generierung einer RTF-Datei.
	 * 
	 * @param src Quell-Datei; FO-Datei, wenn xslt null.
	 * @param xslt Transform-Datei kann null sein.
	 * @param pdfDatei Ergebnis als PDF-Datei.
	 * @throws JhhFopException
	 */
	public void machRtf(Source src, Source xslt, String pdfDatei, OutputStream os) {
		machFop(src, xslt, pdfDatei, os, MimeConstants.MIME_RTF);
	}

	/**
	 * @param src Quell-Datei; FO-Datei, wenn xslt null.
	 * @param xslt Transform-Datei kann null sein.
	 * @param pdfDatei Ergebnis als PDF-Datei.
	 * @param mimeType Mime-Type
	 * @throws JhhFopException
	 */
	private void machFop(Source src, Source xslt, String pdfDatei, OutputStream os, String mimeType) {

		OutputStream out = null;

		try {
			if (pdfDatei == null) {
				out = new BufferedOutputStream(os);
			} else {
				out = new BufferedOutputStream(new FileOutputStream(new File(pdfDatei)));
			}
			//FOUserAgent foUserAgent = getFopFactory().newFOUserAgent();
			// log.error("BaseURL: " + foUserAgent.getBaseURL());
			//foUserAgent.getEventBroadcaster().addEventListener(
			//		new SysOutEventListener());
			//Fop fop = getFopFactory().newFop(mimeType, foUserAgent, out);
			Fop fop = getFopFactory().newFop(mimeType, out);
			TransformerFactory factory = TransformerFactory.newInstance();
			Transformer transformer = null;
			if (xslt == null) {
				transformer = factory.newTransformer();
			} else {
				transformer = factory.newTransformer(xslt);
			}
			Result res = new SAXResult(fop.getDefaultHandler());
			transformer.transform(src, res);
		} catch (Exception ex) {
			//log.error("", ex);
			throw new JhhFopException(ex);
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

}
