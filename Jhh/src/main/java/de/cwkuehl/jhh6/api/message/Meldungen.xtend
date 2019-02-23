package de.cwkuehl.jhh6.api.message

import de.cwkuehl.jhh6.generator.Externalized

@Externalized
class Meldungen {

	// val MTEST = "ÄÖÜäöüß"
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
	val AD011 = "Are You sure to import addresses?"
	val AD012 = "Address list"
	val AD013 = "Person {0}"
	val AD014 = "Site"
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
	val FZ008 = " ({0,number,#,##0.0000}%)"
	val FZ009 = "English books: {0,number}"
	val FZ010 = "Perry Rhodan booklets: {0,number}"
	val FZ011 = "PR booklets read: {0,number}"
	val FZ012 = "Book pages read: {0,number}"
	val FZ013 = "PR pages read: {0,number}"
	val FZ014 = "Pages read: {0,number}"
	val FZ015 = "Pages read per day: {0,number,#,##0.0000}"
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
	val FZ044 = "Mileages per year"
	val FZ045 = "Average per year"
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
	val HH018 = "There is no suitable period. Create new period."
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
	val HH050 = "The file is too short."
	val HH051 = "The column {0} is missing."
	val HH052 = "Are You sure to import the bookings?"
	val HH053 = "{0,number} booking(s) imported."
	val HH054 = "Records: {0,number}  Sum: {1,number,#,##0.00}"
	val HH055 = "  Balance: {0,number,#,##0.00}"
	val HH056 = "Bookings"
	val HH057 = "{0,date,yyyy-MM-dd}, {1,number,#,##0.00}, {2} to {3}, {4}"
	var HH058 = ", {0}"
	val HH059 = ", {0,date,yyyy-MM-dd}"
	val HH060 = "Calculating balance sheets ..."
	val HH061 = "Balance sheets calculated: {0}"
	val HH062 = "Balance record is missing. (Period {0,number}, account {1})"
	val HH063 = "The cash auditors did the cash auditing {0} for {1}."
	val HH064 = "The correct cash management is confirmed."
	val HH065 = "Revenues"
	val HH066 = "Expenditure"
	val HH067 = "Balance"
	val HH068 = "Sum"
	val HH069 = "Signature of cash auditor"
	val HH070 = "Breakdown {0}"
	val HH071 = "Inventory {0} {1,date,yyyy-MM-dd}"
	val HH072 = "Inventory {0}"
	val HH073 = "Sum {0} {1,date,yyyy-MM-dd}"
	val HH074 = "The sum is incorrect. Calculate the period."
	val HH075 = "{0,date,yyyy-MM}"
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
	val HP018 = "Patient record"
	val HP019 = "Invoice"
	val HP020 = "born {0,date,yyyy-MM-dd}"
	val HP021 = "{0,date,yyyy-MM-dd} - {1,date,yyyy-MM-dd}"
	val HP022 = "{0,date,yyyy-MM-dd}"
	val HP023 = "Dear Madam {0},"
	val HP024 = "Dear Sir {0},"
	val HP025 = "Tel. {0}"
	val HP026 = "Tax number: {0}"
	val HP027 = "Bank account: {0}"
	val HP028 = "Invoice:"
	val HP029 = "Date:"
	val HP030 = "Patient:"
	val HP031 = "Diagnosis:"
	val HP032 = "Date;Code;Code 2;Service: expenditure of time where appropriate;Amount"
	val HP033 = "Please transfer the amount until {0,date,yyyy-MM-dd}."
	val HP034 = "Total amount"
	val HP035 = "Image {0} can not be loaded."
	val MO001 = " MANUAL!"
	val MO002 = " with "
	val MO003 = " FLAMBO!"
	val MO004 = "Flambo"
	val MO005 = "Service"
	val MO006 = "Type in a name."
	val MO007 = "Type in services and minimal amount of acolyte, separated by semicolon."
	val MO008 = "Service {0} is missing."
	val MO009 = "The value {0} is not numeric."
	val MO010 = "Acolyte parameter {0} is missing."
	val MO011 = "The profile is used for divine services and cannot be deleted."
	val MO012 = "The acolyte serves with one another and cannot be deleted."
	val MO013 = "Select a profile."
	val MO014 = "There are too few acolyte dispositioned for the service {0}."
	val MO015 = "{0,number} divine services are imported."
	val MO016 = "Select an entry date."
	val MO017 = "Select at least one service."
	val MO018 = "Select at least one availability."
	val MO019 = "The serving with yourself is useless."
	val MO020 = "There are no divine services with dispositions."
	val MO021 = "The file is too short."
	val MO022 = "The column {0} is missing."
	val MO023 = "{0,number} acolyte(s) imported."
	val MO024 = "The 2nd acolyte in row {0,number} is missing."
	val MO025 = "The 2nd acolyte in row {0,number} is ambiguous."
	val MO026 = "The acolyte in row {0,number} is ambiguous."
	val MO027 = "Unknown time."
	val MO028 = "Unknown service date."
	val MO029 = "Unknown year."
	val MO030 = "Acolyte {0} {1} is missing."
	val MO031 = "Divine service is missing."
	val MO032 = "Are You sure to import the acolytes?"
	val MO033 = "Are You sure to import divine service orders?"
	val MO034 = "Select an acolyte."
	val MO035 = "Select a service."
	val MO036 = "Acolyte_service_{0,date,yyyyMMdd}_{1,date,MMdd}"
	val MO037 = "Divine service dispositions for {0}"
	val MO038 = "{0,date,EEEE yyyy-MM-dd, HH:mm}"
	val SB001 = "Type in a maiden name."
	val SB002 = "New spouse and new parents are not possible."
	val SB003 = "Date {0} could not be parsed."
	val SB004 = "Select ancestor or family."
	val SB005 = "Select a type."
	val SB006 = "Select a date type."
	val SB007 = "Father or mother are necessary."
	val SB008 = "New father is not male."
	val SB009 = "New mother is not female."
	val SB010 = "Family number {0} has same father and mother."
	val SB011 = "Family and child are necessary."
	val SB012 = "Ancestor is already child in family {0}."
	val SB013 = "Type in an author."
	val SB014 = "Type in a description."
	val SB015 = "The reference is used by ancestors and cannot be deleted."
	val SB016 = "The reference is used by events and cannot be deleted."
	val SB017 = "Ancestor {0} is missing."
	val SB018 = "List of descendants from {0,date,yyyy-MM-dd HH:mm:ss}"
	val SB019 = "Ancestor {0} with max. {1,number} generations"
	val SB020 = "List of forbears from {0,date,yyyy-MM-dd HH:mm:ss}"
	val SB021 = "Ancestor {0} with max. {1,number} generations{2}"
	val SB022 = " and siblings"
	val SB023 = "Type in a name."
	val SB024 = "Wrong GEDCOM version."
	val SB025 = "Wrong filter criteria (e.g. status1<=1900)."
	val SB026 = "{0,number} person(s) are imported."
	val SB027 = "No family existing."
	val SB028 = "Records: {0,number}  Without date of birth: {1,number}"
	val SB029 = "Are You sure to delete the whole family tree?"
	val SB030 = "Ancestor_list"
	val SB031 = "about {0}"
	val SB032 = "after {0}"
	val SB033 = "before {0}"
	val SB034 = "{0} - {1}"
	val SB035 = "{0} or {1}"
	val SO001 = "Type in the players, separated by semicolon:"
	val SO002 = "{0,number} cell(s) filled."
	val SO003 = "Contradiction in row {0,number} and column {1,number}."
	val SO004 = "Contradiction in row ({0,number}, {1,number})."
	val SO005 = "Contradiction in column ({0,number}, {1,number})."
	val SO006 = "Contradiction in box ({0,number}, {1,number})."
	val SO007 = "Contradiction in row {0,number} with number {1,number}."
	val SO008 = "Contradiction in column {0,number} with number {1,number}."
	val SO009 = "Contradiction in box {0,number} with number {1,number}."
	val SO010 = "Contradiction in diagonal {0,number} row {1,number} with number {2,number}."
	val SO011 = "Sudoku is completely solved."
	val SO012 = "Sudoku is not solvable (no variant)."
	val SO013 = "Sudoku is solvable, but not unambiguous."
	val SO014 = "There is no number any more."
	val SO015 = "Sudoku is not completely solvable."
	val SO016 = "Someone else has the suspect."
	val SO017 = "Someone else has the weapon."
	val SO018 = "Someone else has the room."
	val SO019 = "Select a player"
	val TB001 = "The parameter {0} is invalid."
	val TB002 = "Report: {0,date,yyyy-MM-dd HH:mm:ss}{1}"
	val TB003 = "Search: (/{0}/ or /{1}/ or /{2}/) and (/{3}/ or /{4}/ or /{5}/) and not (/{6}/ or /{7}/ or /{8}/){9}"
	val TB004 = "Wrong counter at {0,date,yyyy-MM-dd}: {1}, expected: {2}"
	val TB005 = "Diary"
	val VM001 = "Type in a description."
	val VM002 = "Select a house."
	val VM003 = "The house is used for flats and cannot be deleted."
	val VM004 = "The flat is used for renters and cannot be deleted."
	val VM005 = "The flat is used for rents and cannot be deleted."
	val VM006 = "Select an apartment."
	val VM007 = "Type in a key."
	val VM008 = "Type in a name."
	val VM009 = "Select a move-in date."
	val VM010 = "Renter list {0} from {1,date,yyyy-MM-dd HH:mm:ss}"
	val VM011 = "empty"
	val VM012 = "from: "
	val VM013 = "  Rent: "
	val VM014 = "  Parking: "
	val VM015 = "  Operat.: "
	val VM016 = "  Heating: "
	val VM017 = "  Sum: "
	val VM018 = "  Pers.: "
	val VM019 = "Select a date."
	val VM020 = "Select a house or an apartment."
	val VM021 = "No booking committed."
	val VM022 = "Rental debit position {0,date,MM/yyyy} {1} {2}"
	val VM023 = "Add. debit position {0,date,MM/yyyy} {1} {2}"
	val VM024 = "Select a renter."
	val VM025 = "Type in amounts."
	val VM026 = "Renter number {0} (at this date) is missing."
	val VM027 = "Rent account with key {0} is missing."
	val VM028 = "No house accounting found."
	val VM029 = "Rental payment {0,date,MM/yyyy} {1} {2}"
	val VM030 = "Add. payment {0,date,MM/yyyy} {1} {2}"
	val VM031 = "Renter_list"
	val VM032 = "Accounting"
	val VM033 = "Accounting of operating and heating costs {0,number,0} for property {1}:"
	val VM034 = "Your affected period: {0}"
	val VM035 = "Cost type"
	val VM036 = "Costs in {0}"
	val VM037 = "Your share"
	val VM038 = "Your amount"
	val VM039 = "Other operating costs"
	val VM040 = "Sum"
	val VM041 = "Apportionment on m² living space (total {0,number,#,##0.00} m²)"
	val VM042 = "Share per m²: {0} : {1,number,#,##0.00} m² ="
	val VM043 = "Your share: {0} x {1,number,#,##0.00} m²{2}"
	val VM044 = "Water supply and drainage"
	val VM045 = "Apportionment on person months (total {0,number,0})"
	val VM046 = "Share per person month: {0} : {1,number,0} ="
	val VM047 = "Your share: {0} x {1,number,0} person months"
	val VM048 = "Costs of common antenna"
	val VM049 = "Per apartment and month"
	val VM050 = "Your share: {0} x {1,number,0} months"
	val VM051 = "Less any prepayments (without heating)"
	val VM052 = "Your\u00A0credit"
	val VM053 = "Your\u00A0add.\u00A0payment"
	val VM054 = "Heating costs"
	val VM055 = "The attached calculation of heating costs {0,number,0} is resulting in a credit."
	val VM056 = "The attached calculation of heating costs {0,number,0} is resulting in an additional payment."
	val VM057 = "Full settlement of operational costs {0,number,0} "
	val VM058 = "Flat;Renter;Move-in;Move-out;m²;Basic r.;Deposit;Ant."
	val WP001 = "Type in a description."
	val WP002 = "Select a state."
	val WP003 = "The box size must be greater than 0."
	val WP004 = "The reversal must be greater than 0."
	val WP005 = "Wrong method."
	val WP006 = "The period must be greater than 10 days."
	val WP007 = "Wrong scaling method."
	val WP008 = "({0,number} of {1,number}) Calculation of {2} from {3,date,yyyy-MM-dd} {4}"
	val WP009 = "without configuration"
	val WP010 = "without"
	val WP012 = "State {0,number} at {1}"
	val WP013 = "Stock{0}"
	val WP014 = "Type in a shortcut."
	val WP015 = "The stock is used by relations and cannot be deleted."
	val WP016 = "The stock is used by investments and cannot be deleted."
	val WP017 = "Select a stock."
	val WP018 = "The investment is used by bookings and cannot be deleted."
	val WP019 = "Select an investment."
	val WP020 = "Select a value date."
	val WP021 = "The posting text must not be empty."
	val WP022 = "Type in a value for payment or shares."
	val WP023 = "Payment amount:  {0,number,#,##0.00}\nShares:          {1,number,#,##0.00000}\nPrice per share: {2,number,#,##0.0000}\nInterest:        {3,number,#,##0.00}\n{4}"
	val WP024 = "Actual price:    {0,number,#,##0.0000}{1}\nActual value:    {2,number,#,##0.00}\nProfit or loss:  {3,number,#,##0.00} ({4,number,#,##0.0000}%)"
	val WP025 = " ({0} {1,number,#,##0.0000}){2}"
	val WP026 = " ({0,date,yyyy-MM-dd})"
	val WP027 = "Preparing ..."
	val WP029 = "Records: {0,number}  Sum: {1,number,#,##0.00}  Value: {2,number,#,##0.00}  Profit: {3,number,#,##0.00}"
	val WP030 = "{0,date,yyyy-MM-dd}, Payment {1}, Discount {2}, Shares {3}, Interest {4}, {5}, {6}"
	val WP031 = "Closing price is missing."
	val WP032 = "High or low price is missing."
	val WP033 = "Opening, high, low or closing price is missing."
	val WP034 = "High, low or closing price is missing."
	val WP035 = "Box"
	val WP036 = "fix"
	val WP037 = "percentage"
	val WP038 = "dynamic"
	val WP039 = "Reversal {0,number}"
	val WP040 = "High low trend"
	val WP041 = "High low trend reversal"
	val WP042 = "Open high low close"
	val WP043 = "Typical price"
	val WP044 = "Close"
	val WP045 = "relative"
	val WP046 = "{0,number} days"
	val WP047 = "{0,date,yyyy-MM-dd} - {1,date,yyyy-MM-dd}"
	val WP048 = "{0} {1,number,#,##0.00}"
	val WP049 = "Get a free access key from https://fixer.io and type in to option WP_FIXER_IO_ACCESS_KEY."
	val WP050 = "The description is too long."
	val M1000 = "The class {0} cannot be instantiated."
	val M1001 = "RbRepository for class {0} is missing."
	val M1002 = "Replication UID is missing."
	val M1003 = "No copy between identical replication UIDs."
	val M1004 = "A replication is already running."
	val M1005 = "The parameter DB_VERSION is different. Change the database structure."
	val M1006 = "Table {0}"
	val M1007 = "{0,number} Data records so far"
	val M1008 = "Abort"
	val M1009 = "Client copy finished."
	var M1010 = "Are You sure to copy the client?"
	val M1011 = "{0,date,yyyy-MM-dd HH:mm:ss} of {1}"
	val M1012 = "Select a file."
	val M1013 = "Select a record."
	val M1014 = "The file {0} is too long."
	val M1015 = "The file {0} can not be read completely."
	val M1016 = "Unknown Exception."
	val M1017 = "Start the latest version of JHH4 to change the database."
	val M1018 = "The replication database is not available."
	val M1019 = "CSV parse error at character {0,number} in row\n{1}."
	val M1020 = "CSV parse error in row\n{0}."
	val M1021 = "JHH6 arguments: {0}"
	val M1022 = " (not logged in)"
	val M1023 = " (Client {0,number})"
	val M1024 = "Test-"
	val M1025 = "Type {0} is missing."
	val M1026 = " Property file for program JHH6"
	val M1027 = "The JAVA version is not supporting AWT-Desktop."
	val M1028 = "Input"
	val M1029 = "Wrong parameter for image."
	val M1030 = "Cancellation because of circular reference."
	val M1031 = "Preparing ..."
	val M1032 = "Copying ..."
	val M1033 = "Error: {0}"
	val M1034 = "The target folder must be separated by '<'."
	val M1035 = "The target folder must not be empty."
	val M1036 = "The source folders are missing."
	var M1037 = "The source folder must not be empty."
	val M1038 = "The path {0} is not a folder."
	val M1039 = "The restore is only possible without differential backup."
	val M1040 = "The backup is not possible because of existing differential backup."
	val M1041 = "The backup is not completely initialized."
	val M1042 = "{0,number}/{1,number} ({2,number} Errors) {3}"
	val M1043 = "Cancelled because of too many errors."
	val M1044 = "Cancelled by user."
	val M1045 = "Ended with {0,number} changes."
	val M1046 = "There is no document to print."
	val M1047 = "Wrong number of inserted records."
	val M1048 = "Wrong number of updated records."
	val M1049 = "Wrong number of deleted records."
	val M1050 = "{0,number} records of table {1} reconciled."
	val M1051 = "Primary key of table {0} is too long."
	val M1052 = "{0,number} of {1,number} records of table {2} copied."
	val M1053 = "{0,number} records of table {1} compared."
	val M1054 = "Table {0} on the server has fewer records. (1)"
	val M1055 = "Table {0} has different values in record {1,number} and column {2,number}. (2)"
	val M1056 = "Table {0} on the client has fewer records. (3)"
	val M1057 = "Binding for interface {0} is missing."
	val M1058 = "Page "
	val M2001 = "Delete"
	val M2004 = "_OK and new"
	val M2005 = "Cancel reverse"
	val M2006 = "Reverse"
	val M2022 = "Select a backup folder."
	val M2023 = "Type in a target folder."
	val M2024 = "Type in at least one source folder."
	val M2094 = "Select a stock."
	val M2095 = "Select a configuration."
	val M3000 = "The help file ({0}) is missing."
	val M3001 = "There is an update available. Please close the application and start the batch file #InstallUpdateJhh6."
	val M3002 = "The program is up to date."
	val M9000 = "Example"
	val M9001 = "Example2"
	val M9002 = "Example3"
}
