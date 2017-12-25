package de.cwkuehl.jhh6.server.service.impl;

import java.util.ArrayList;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class MoLexer {

    public static class Token {

        public TokenType type;
        public String    data;

        public Token(TokenType type, String data) {

            this.type = type;
            this.data = data;
        }

        @Override
        public String toString() {
            return String.format("(%s %s)", type.name(), data);
        }
    }

    public static ArrayList<Token> lex(String input) {

        // The tokens to return
        ArrayList<Token> tokens = new ArrayList<Token>();

        // Lexer logic begins here
        StringBuffer tokenPatternsBuffer = new StringBuffer();
        for (TokenType tokenType : TokenType.values()) {
            tokenPatternsBuffer.append(String.format("|(?<%s>%s)", tokenType.name(), tokenType.pattern));
        }
        Pattern tokenPatterns = Pattern.compile(new String(tokenPatternsBuffer.substring(1)), Pattern.CASE_INSENSITIVE
                | Pattern.MULTILINE);

        // Begin matching tokens
        Matcher matcher = tokenPatterns.matcher(input);
        String m = null;
        while (matcher.find()) {
            for (TokenType e : TokenType.values()) {
                m = matcher.group(e.name());
                if (matcher.group(e.name()) != null && !e.equals(TokenType.WHITESPACE)) {
                    tokens.add(new Token(e, m));
                    break;
                }
            }
        }

        return tokens;
    }

    public static enum TokenType {

        MDO("Messdienerordnung"), VOM("\\bvom\\b"), UHR("\\bUhr\\b"), DATUM("[0-9]{1,2}\\.[0-9]{1,2}\\.[0-9]{2,4}"), DATUMZEIT(
                "[0-9]{1,2}[\\.:][0-9]{1,2}"), ZEIT("[0-9]{1,2}"), WOCHENTAG(
                "(Montag|Dienstag|Mittwoch|Donnerstag|Freitag|Samstag|Sonntag)"), MESSE(
                "(Fruehmesse|Frühmesse|Hochamt|Vorabendmesse|Abendmesse|Hl. Messe"
                        + "|Jahresschlussmesse|Hirtenmesse|Vesper|Familiengottesdienst|Ökum. Familiengottesdienst"
                        + "|Jugendgottesdienst|Aschermittwochsgottesdienst|Palmsonntag-Gottesdienst"
                        + "|Gründonnerstag-Gottesdienst|Karfreitag-Gottesdienst|Ostersonntag-Gottesdienst"
                        + "|Osternacht-Gottesdienst|Weißer Sonntag|Weißer Montag)"), DIENST(
                "(Altar|Flambo|Fahnen|Buch|Zeremoniar|Akolyten|Weihrauch|Weihwasser|Kreuz)[ \t]*:"), ORT(
                "(Pfarrkirche|CAZ|Caritas-Zentrum|Kapelle)"), NAMENSTEIL("[a-zäöüß][a-zäöüß\\-\\.]*"), MIN("[-|–]"), WHITESPACE(
                "[ \t\f]+"), CRLF("[\r|\n]+");

        public final String pattern;

        private TokenType(String pattern) {
            this.pattern = pattern;
        }

    }

}
