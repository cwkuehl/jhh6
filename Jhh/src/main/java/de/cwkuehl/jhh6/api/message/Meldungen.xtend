package de.cwkuehl.jhh6.api.message

import de.cwkuehl.jhh6.generator.Externalized

@Externalized
class Meldungen {

	// val MTEST = "ÄÖÜäöüß"
	// val M1000 = "You are not logged in."
	// val M1001 = "Sie sind für die Funktion nicht berechtigt."
	// val M1002 = "Mandant-Einstellung {0} fehlt."
	val AD001 = "Birthdays between {0,date,yyyy-MM-dd} and {1,date,yyyy-MM-dd}:"
	val AD002 = "{0,date,yyyy-MM-dd} {1} ({2,number} years)"
	val AD003 = "Address list from {0,date,yyyy-MM-dd HH:mm:ss}"
	val AD004 = "All addresses deleted."
	val AD005 = "Column headers do not fit."
	val AD006 = "Column headers are missing in 1st row."
	val AD007 = "Person import error."
	val AD008 = "Site import error."
	val AD009 = "Address import error."
	val AD010 = "{0,number} person(s), {2,number} site(s) and {4,number} address(es) imported.\nThere are with {1,number} person(s), {3,number} site(s) and {5,number} address(es)."
	val AM001 = "Invalid login."
	val AM002 = "The new password must not be empty."
	val AM003 = "User {0,number}/{1} exists."
	val AM004 = "The actual client cannot be deleted."
	val AM005 = "Are You sure to delete the client with all data?"
	val AM006 = "The user doesn't have All permission."
	val AM007 = "The user doesn't have Admin permission."
	val AM008 = "Type in a description."
	val AM009 = "The user ID must not be empty."
	val AM010 = "You must not grant a permission you don't possess."
	val AM011 = "The user ID must be unambiguous."
	val FZ001 = "{0} ({1,date,yyyy-MM-dd}): {2,number,#,##0.00}"
	val FZ002 = " ({0})"
	val FZ003 = "Person: {0}"
	val FZ004 = "Days of life: {0,number}"
	val FZ005 = "Number of books: {0,number}"
	val FZ006 = "Read:  {0,number}"
	val FZ007 = "Heard: {0,number}"
	val FZ008 = " ({0,number,0.0000}%)"
	val FZ009 = "English books: {0,number}"
	val FZ010 = "Perry Rhodan booklets: {0,number}"
	val FZ011 = "PR booklets read: {0,number}"
	val FZ012 = "Book pages read: {0,number}"
	val FZ013 = "PR pages read: {0,number}"
	val FZ014 = "Pages read: {0,number}"
	val FZ015 = "Pages read per day: {0,number,0.0000}"
	val FZ016 = "{0}{1,number} ({2,number}) km"
	val FZ017 = "{0}{1,number} km/day ({2,number} km/year)"
	val FZ018 = "Sum"
	val FZ019 = "Select a bike."
	val FZ020 = "Type in a positive odometer reading."
	val FZ021 = "Type in a positive km."
	val FZ022 = "Type in a positive average."
	val FZ023 = "Type in a date."
	val FZ024 = "Bike {0} is missing."
	val FZ025 = "The odometer reading must be greater or equal to {0,number}."
	val FZ026 = "Mileages could only be added at the end."
	val FZ027 = "The odometer reading could only be set to 0 at the end."
	val FZ028 = "No tour."
	val FZ029 = "Mileage {0,number} is missing."
	val FZ030 = "The following km would be negative."
	val FZ031 = "Only the last mileage can be deleted."
	val FZ032 = "Type in an author name."
	val FZ033 = "Type in a series name."
	val FZ034 = "No series"
	val FZ035 = "Type in a topic."
	val FZ036 = "User {0} is missing."
	val FZ037 = "Type in a description."
	val FZ038 = "Select a type."
	val FZ039 = "The author is used by books and cannot be deleted."
	val FZ040 = "The series is used by books and cannot be deleted."
	val FZ041 = "Type in a title."
	val FZ042 = "Select an author."
	val FZ043 = "Select a series."
	val HH001 = "Equity capital"
	val HH002 = "Profit and loss"
	val HH003 = "No periods found."
	val HH004 = "The last period cannot be deleted."
	val HH005 = "Period {0,number} is missing."
	val HH006 = "{0,number,0000000000}{1}{2}{3}"
	val HH007 = "Type in a description."
	val HH008 = "The account type {0} is invalid."
	val HH009 = "The account attribute {0} is invalid or more than 1 character."
	val HH010 = "There is already an account with attribute {0}."	
	val HH011 = "The account must not be timely limited."
	val HH012 = "The account type must not be changed."
	val HH013 = "The account attribute {0} must not be changed."
	val HH014 = "There are bookings before the period of validity."
	val HH015 = "The valid to date must not be before valid from date."
	val HH016 = "There are bookings after the period of validity."
	val HH017 = "There is already an account with description {0}."
	val HH018 = "There is no suitable periode. Create new period."
	val HH019 = "Account number {0} is missing."
	val HH020 = "The account is used for bookings and cannot be deleted."
	val HH021 = "The equity capital account and profit and loss account can not be deleted."
	val HH022 = "No bookings."
	val HH023 = "Bookings from {0,date,yyyy-MM-dd} to {1,date,yyyy-MM-dd}"
	val HH024 = "Type in a description."
	val HH025 = "Event{0}"
	val HH026 = "The attribute must be no longer than {0,number} characters."
	val HH027 = "The posting text must not be empty."
	val HH028 = "Select a debit account."
	val HH029 = "Select a credit account."
	val HH030 = "The debit account must be different from the credit account."
	val HH031 = "The equity capital account can not be found."
	val HH032 = "The profit and loss account can not be found."
	val HH033 = "Select a value date."
	val HH034 = "The value must be greater than 0."
	val HH035 = "The equity capital account and profit and loss account are not bookable."
	val HH036 = "Select a receipt date."
	val HH037 = "The debit account is not found."
	val HH038 = "The debit account is valid from {0,date,yyyy-MM-dd}."
	val HH039 = "The debit account is valid to {0,date,yyyy-MM-dd}."
	val HH040 = "The credit account is not found."
	val HH041 = "The credit account is valid from {0,date,yyyy-MM-dd}."
	val HH042 = "The credit account is valid to {0,date,yyyy-MM-dd}."
	val HH043 = "Booking number {0} is missing."
	val HH044 = "Select two account for changing."
	val HH045 = "Type in a report title."
	val HH046 = "Annual report {0} for {1} of {2,date,dd.MM.yyyy HH:mm:ss}"
	val HH047 = "Cash report {0} for {1} of {2,date,dd.MM.yyyy HH:mm:ss}"
	val HH048 = "Annual report"
	val HH049 = "Cash report"
	val HP001 = "No default"
	val HP002 = "Default for treatment"
	val HP003 = "Default for invoice"
	val HP004 = "State{0}"
	val HP005 = "Description{0}"
	val HP006 = "C{0}"
	val HP007 = "The service is used by treatments or service groups and cannot be deleted."
	val HP008 = "Select a service."
	val HP009 = "N{0}"
	val HP010 = "The patient is receiving invoices and cannot be deleted."
	val HP011 = "Select a patient."
	val HP012 = "Select a date."
	val HP013 = "Select a treatment."
	val HP014 = "An invoice cannot be saved without an amount."
	val HP015 = "Select an invoice."
	val HP016 = "Select a state."
	val HP017 = "The state is used for treatments and cannot be deleted."
	val MO001 = " MANUAL!"
	val MO002 = " with "
	val MO003 = " FLAMBO!"
	val M1000 = "The class {0} cannot be instantiated."
	val M1007 = "The parameter {0} is invalid."
	val M1008 = "Report: {0,date,yyyy-MM-dd HH:mm:ss}{1}"
	val M1009 = "Search: (/{0}/ or /{1}/ or /{2}/) and (/{3}/ or /{4}/ or /{5}/) and not (/{6}/ or /{7}/ or /{8}/){9}"
	val M1010 = "Wrong counter at {0,date,yyyy-MM-dd}: {1}, expected: {2}"
	val M1011 = "{0,date,yyyy-MM-dd HH:mm:ss} of {1}"
	// val M1012 = "Bitte geben Sie einen Benutzer ein."
	// val M1013 = "Die Kennwortwiederholung ist falsch."
	// val M1014 = "Sind Sie sicher, die %1$s zu löschen?"
	// val M1015 = "Es ist ein unerwarteter Anwendungsfehler aufgetreten. Bitte benachrichtigen Sie Ihren zuständigen Administrator."
	// val M1016 = "Kein Kontext vorhanden."
	val M1017 = "Start the latest version of JHH4 to change the database."
	val M1018 = "The replication database is not available."
	val M2001 = "Delete"
	val M2004 = "_OK and new"
	val M2005 = "Cancel reverse"
	val M2006 = "Reverse"
	val M2007 = "Select a house."
	val M2008 = "Select an appartment."
	val M2009 = "Select a tenant."
	val M2010 = "Select a rent."
	val M2014 = "Type in a key."
	val M2018 = "The house is used for flats and cannot be deleted."
	val M2019 = "The flat is used for renters and cannot be deleted."
	val M2020 = "The flat is used for rents and cannot be deleted."
	val M2021 = "Select a record."
	val M2022 = "Select a backup folder."
	val M2023 = "Type in a target folder."
	val M2024 = "Type in at least one source folder."
	val M2050 = "No family existing."
	val M2051 = "The reference is used by ancestors and cannot be deleted."
	val M2052 = "The reference is used by events and cannot be deleted."
	val M2053 = "Records: {0,number}  Without date of birth: {1,number}"
	val M2054 = "Are You sure to delete the whole family tree?"
	val M2055 = "{0,number} person(s) are imported."
	val M2056 = "Are You sure to import addresses?"
	var M2057 = "Are You sure to copy the client?"
	val M2058 = "Select a file."
	val M2076 = "The acolyte serves with one another and cannot be deleted."
	val M2078 = "Are You sure to import the acolytes?"
	val M2081 = "The profile is used for devine services and cannot be deleted."
	val M2082 = "Are You sure to import devine service orders?"
	val M2083 = "{0,number} devine services are imported."
	val M2085 = "Select an acolyte."
	val M2086 = "Select a service."
	val M2087 = "Select a profile."
	val M2088 = "Type in a name."
	val M2089 = "Type in services and minimal amout of acolyte, separatd by semicolon."
	val M2090 = "Acolyte disposition {0} is missing."
	val M2091 = "Service {0} is missing."
	val M2092 = "The value {0} is not numeric."
	val M2093 = "There are too few acolyte dispositioned for the service {0}."
	val M2094 = "Select a stock."
	val M2095 = "Select a configuration."
	val M3000 = "The help file ({0}) is missing."
	val M3001 = "There is an update available. Please close the application and start the batch file #InstallUpdateJhh6."
	val M9000 = "Example"
	val M9001 = "Example2"
	val M9002 = "Example3"
}
