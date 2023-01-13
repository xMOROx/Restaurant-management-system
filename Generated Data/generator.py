import datetime
from faker import Faker
import random

f = Faker(["pl_PL"])

payment_statuses = [
    "Paid in full",
    "Partial payment received",
    "Payment pending",
    "Payment overdue",
    "Payment failed",
    "Payment refunded",
    "Payment cancelled",
    "Payment in process",
    "Payment on hold",
    "Payment not required",
    "Payment not accepted",
    "Payment not applicable",
    "Payment not authorized",
    "Payment received",
    "Payment submitted",
    "Payment confirmed",
    "Payment processed",
    "Payment completed",
    "Payment acknowledged",
    "Payment reconciled",
    "Payment settled",
    "Payment verified",
    "Payment approved",
    "Payment declined",
    "Payment rejected",
    "Payment disputed",
    "Payment cancelled by customer",
    "Payment cancelled by merchant",
    "Payment delayed",
    "Payment re-submitted",
    "Payment rescheduled",
    "Payment refund requested",
    "Payment refunded partially",
    "Payment refunded in full",
    "Payment in transit",
    "Payment in dispute",
    "Payment under review",
    "Payment not yet cleared",
    "Payment not yet processed",
    "Payment not yet approved",
    "Payment not yet completed",
    "Payment not yet reconciled",
    "Payment not yet settled",
    "Payment not yet verified",
    "Payment not yet acknowledged",
    "Payment not yet acknowledged by bank",
    "Payment not yet acknowledged by merchant",
    "Payment not yet acknowledged by customer",
    "Payment not yet acknowledged by system",
    "Payment not yet acknowledged by payment gateway",
    "Payment not yet acknowledged by financial institution",
    "Payment not yet acknowledged by processor",
    "Payment not yet acknowledged by issuer",
    "Payment not yet acknowledged by acquirer",
    "Payment not yet acknowledged by network",
    "Payment not yet acknowledged by clearing house",
    "Payment not yet acknowledged by settlement institution",
]

# for status in payment_statuses:
#     print(f"EXEC AddPaymentStatus '{status}'")

cities_and_towns = list(
    set(
        [
            "Kutno",
            "Kędzierzyn-Koźle",
            "Zduńska Wola",
            "Tarnobrzeg",
            "Chorzów",
            "Polkowice",
            "Nowy Targ",
            "Łowicz",
            "Tychy",
            "Kwidzyn",
            "Skierniewice",
            "Września",
            "Zgorzelec",
            "Dzierżoniów",
            "Żywiec",
            "Kościan",
            "Świecie",
            "Brzeg",
            "Kościerzyna",
            "Inowrocław",
            "Koszalin",
            "Mikołów",
            "Legionowo",
            "Biała Podlaska",
            "Kluczbork",
            "Czeladź",
            "Bochnia",
            "Ruda Śląska",
            "Łuków",
            "Siedlce",
            "Lublin",
            "Chrzanów",
            "Jarocin",
            "Katowice",
            "Bartoszyce",
            "Ostróda",
            "Chełm",
            "Augustów",
            "Żagań",
            "Świętochłowice",
            "Wołomin",
            "Zawiercie",
            "Poznań",
            "Siemianowice Śląskie",
            "Chojnice",
            "Kalisz",
            "Ząbki",
            "Wałbrzych",
            "Ciechanów",
            "Płock",
            "Mysłowice",
            "Sopot",
            "Gdańsk",
            "Pruszcz Gdański",
            "Gliwice",
            "Kętrzyn",
            "Oświęcim",
            "Jasło",
            "Giżycko",
            "Lubin",
            "Nowa Ruda",
            "Mława",
            "Płońsk",
            "Jaworzno",
            "Przemyśl",
            "Mińsk Mazowiecki",
            "Wrocław",
            "Sieradz",
            "Piekary Śląskie",
            "Nysa",
            "Grudziądz",
            "Koło",
            "Gdynia",
            "Tarnów",
            "Świdnica",
            "Luboń",
            "Goleniów",
            "Zakopane",
            "Sandomierz",
            "Zamość",
            "Dębica",
            "Piaseczno",
            "Jastrzębie-Zdrój",
            "Słupsk",
            "Bielawa",
            "Żary",
            "Kłodzko",
            "Włocławek",
            "Żyrardów",
            "Gniezno",
            "Warszawa",
            "Police",
            "Opole",
            "Tczew",
            "Otwock",
            "Tarnowskie Góry",
            "Stalowa Wola",
            "Wodzisław Śląski",
            "Białystok",
            "Pszczyna",
            "Racibórz",
            "Krotoszyn",
            "Marki",
            "Iława",
            "Ełk",
            "Legnica",
            "Wejherowo",
            "Środa Wielkopolska",
            "Mielec",
            "Śrem",
            "Pruszków",
            "Częstochowa",
            "Rzeszów",
            "Starachowice",
            "Gorzów Wielkopolski",
            "Puławy",
            "Olkusz",
            "Świebodzice",
            "Gorlice",
            "Bielsko-Biała",
            "Piła",
            "Toruń",
            "Oława",
            "Oleśnica",
            "Skawina",
            "Świdnik",
            "Łaziska Górne",
            "Kielce",
            "Jarosław",
            "Ostrowiec Świętokrzyski",
            "Stargard Szczeciński",
            "Knurów",
            "Myszków",
            "Swarzędz",
            "Ostrołęka",
            "Łódź",
            "Kołobrzeg",
            "Olsztyn",
            "Suwałki",
            "Będzin",
            "Wyszków",
            "Cieszyn",
            "Czechowice-Dziedzice",
            "Ostrów Wielkopolski",
            "Sochaczew",
            "Biłgoraj",
            "Piotrków Trybunalski",
            "Łomża",
            "Nowy Dwór Mazowiecki",
            "Sosnowiec",
            "Jawor",
            "Świnoujście",
            "Grodzisk Mazowiecki",
            "Dąbrowa Górnicza",
            "Elbląg",
            "Turek",
            "Brodnica",
            "Zielona Góra",
            "Piastów",
            "Rumia",
            "Czerwionka-Leszczyny",
            "Szczecin",
            "Głogów",
            "Szczecinek",
            "Bydgoszcz",
            "Wągrowiec",
            "Bytom",
            "Białogard",
            "Starogard Gdański",
            "Pabianice",
            "Wałcz",
            "Krosno",
            "Sanok",
            "Lubliniec",
            "Skarżysko-Kamienna",
            "Zgierz",
            "Kraśnik",
            "Zabrze",
            "Leszno",
            "Bolesławiec",
            "Szczytno",
            "Nowa Sól",
            "Malbork",
            "Kraków",
            "Ostrów Mazowiecka",
            "Lubartów",
            "Zambrów",
            "Bełchatów",
            "Radom",
            "Nowy Sącz",
            "Radomsko",
            "Jelenia Góra",
            "Lębork",
            "Bielsk Podlaski",
            "Żory",
            "Wieluń",
            "Konin",
            "Reda",
            "Tomaszów Mazowiecki",
            "Rybnik",
        ]
    )
)


# for i in range(500):
#     postal_code = f.postcode()
#     localNR = f.bothify(text="##?", letters="ABCDEFGHIJKLMNOPQRSTUVWXYZ")
#     street = f.street_name()
#     print(
#         "EXEC AddAddress",
#         f"'{street}', '{localNR}', '{postal_code}', '{random.choice(cities_and_towns)}'",
#     )
positions = [
    "Manager",
    "Chef",
    "Sous Chef",
    "Line Cook",
    "Dishwasher",
    "Server",
    "Host/Hostess",
    "Busser",
    "Food Runner",
    "Food Expediter",
    "Cashier",
    "Barista",
    "Pastry Chef",
]

# for i in range(13):
#     LastName = f.last_name()
#     FirstName = f.first_name()
#     position_index = f.unique.random_int(0, 12)
#     email = f.email()
#     phone = f.phone_number()
#     # remove spaces from phone number
#     phone = phone.replace(" ", "")
#     phone = phone.replace("+", "")
#     addressID = random.randint(1, 500)
#     print(
#         "EXEC addStaffMember",
#         f"'{LastName}', '{FirstName}', '{positions[position_index]}', '{email}', '{phone}', {addressID}",
#     )

# for i in range(30):
#     LastName = f.last_name()
#     FirstName = f.first_name()
#     if FirstName[-1] == "a":
#         position = random.choice(["Waitress", "Food Runner", "Busser"])
#     else:
#         position = random.choice(["Waiter", "Food Runner", "Busser"])
#     email = f.email()
#     phone = f.phone_number()
#     # remove spaces from phone number
#     phone = phone.replace(" ", "")
#     phone = phone.replace("+", "")
#     addressID = random.randint(1, 500)
#     print(
#         "EXEC addStaffMember",
#         f"'{LastName}', '{FirstName}', '{position}', '{email}', '{phone}', {addressID}",
# )


# add individual customers

# for i in range(200):
#     client_type = "I"
#     LastName = f.last_name()
#     FirstName = f.first_name()
#     email = f.email()
#     phone = f.phone_number()
#     # remove spaces from phone number
#     phone = phone.replace(" ", "")
#     phone = phone.replace("+", "")
#     addressID = random.randint(1, 500)
#     print(
#         "EXEC addClient",
#         f"@ClientType='{client_type}', @FirstName='{FirstName}', @LastName={LastName}, @Email='{email}', @Phone='{phone}', @AddressID={addressID}",
#     )


# add companies customers

# for i in range(130):
#     client_type = "C"
#     company_name = f.company()
#     email = f.email()
#     phone = f.unique.phone_number()
#     # remove spaces from phone number
#     phone = phone.replace(" ", "")
#     phone = phone.replace("+", "")
#     nip = f.numerify(text="##########")
#     if random.random() < 0.8:
#         krs = f.numerify(text="##########")
#     else:
#         krs = "NULL"
#     if random.random() < 0.8:
#         regon = f.numerify(text="#########")
#     else:
#         regon = "NULL"
#     addressID = random.randint(1, 500)

#     if krs == "NULL" and regon == "NULL":
#         print(
#             "EXEC addClient",
#             f"@ClientType='{client_type}', @CompanyName='{company_name}', @Email='{email}', @Phone='{phone}', @AddressID={addressID}, @NIP='{nip}', @KRS={krs}, @REGON={regon}",
#         )
#     elif krs == "NULL":
#         print(
#             "EXEC addClient",
#             f"@ClientType='{client_type}', @CompanyName='{company_name}', @Email='{email}', @Phone='{phone}', @AddressID={addressID}, @NIP='{nip}', @KRS={krs}, @REGON='{regon}'",
#         )
#     elif regon == "NULL":
#         print(
#             "EXEC addClient",
#             f"@ClientType='{client_type}', @CompanyName='{company_name}', @Email='{email}', @Phone='{phone}', @AddressID={addressID}, @NIP='{nip}', @KRS='{krs}', @REGON={regon}",
#         )
#     else:
#         print(
#             "EXEC addClient",
#             f"@ClientType='{client_type}', @CompanyName='{company_name}', @Email='{email}', @Phone='{phone}', @AddressID={addressID}, @NIP='{nip}', @KRS='{krs}', @REGON='{regon}'",
#         )


# Reservation Vars

# for i in range(200):
#     WZ = random.randint(30, 150)
#     WK = random.randint(5, 30)
#     startDate = f.date_between(start_date="-2y", end_date="-1y")
#     endDate = startDate + datetime.timedelta(days=random.randint(10, 180))
#     print(
#         "EXEC addReservation",
#         f"@WZ={WZ}, @WK={WK}, @StartDate='{startDate}', @EndDate='{endDate}'",
#     )

#  add employees to company

for i in range(90):
    company_id = random.randint(201, 231)
    employee_id = f.unique.random_int(1, 200)
    print(
        "EXEC addEmployeeToCompany", f"@CompanyID={company_id}, @PersonID={employee_id}"
    )
