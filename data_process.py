import pandas as pd
import os
import mssql_python as mssql
from dotenv import load_dotenv

def replace_dot(col):
    if col.dtype == 'object':
        col = col.str.replace(',', '.')
    print("Replace task")
    return col

def load_adag_data():
    #Beolvasás
    adagok_df = pd.read_csv("Adagok.csv", encoding="cp852", delimiter=";")
    #Üres sorok törlése
    adagok = adagok_df[adagok_df['ADAGSZÁM'].isnull() == False]
    adagok['kezdet'] = adagok['Kezdet_DÁTUM'].astype(str) + ' ' + adagok['Kezdet_IDŐ']
    adagok['vege'] = adagok['Vége_DÁTUM'].astype(str) + ' ' + adagok['Vége_IDŐ']
    formatted_adagok = adagok[['ADAGSZÁM', 'kezdet', 'vege']]
    renamed_adagok = formatted_adagok.rename(columns={'ADAGSZÁM': 'adagszam'})
    return renamed_adagok

def load_panel_data():
    panelek_df = pd.read_csv("Hűtőpanelek.csv", delimiter=";")
    #Header list
    headers = list(panelek_df.columns.values)
    formatted_panelek = panelek_df[['Panel hőfok 1 [°C] Time', 'Panel hőfok 1 [°C] ValueY', 'Panel hőfok 2 [°C] ValueY',
                                    'Panel hőfok 3 [°C] ValueY', 'Panel hőfok 4 [°C] ValueY', 'Panel hőfok 5 [°C] ValueY',
                                    'Panel hőfok 6 [°C] ValueY', 'Panel hőfok 8 [°C] ValueY', 'Panel hőfok 9 [°C] ValueY',
                                    'Panel hőfok 10 [°C] ValueY', 'Panel hőfok 11 [°C] ValueY', 'Panel hőfok 12 [°C] ValueY',
                                    'Panel hőfok 13 [°C] ValueY', 'Panel hőfok 14 [°C] ValueY', 'Panel hőfok 15 [°C] ValueY']]
    renamed_panelek = formatted_panelek.rename(columns={'Panel hőfok 1 [°C] Time': 'time', 'Panel hőfok 1 [°C] ValueY': 'panel1',
                                                        'Panel hőfok 2 [°C] ValueY': 'panel2', 'Panel hőfok 3 [°C] ValueY': 'panel3',
                                                        'Panel hőfok 4 [°C] ValueY': 'panel4', 'Panel hőfok 5 [°C] ValueY': 'panel5',
                                                        'Panel hőfok 6 [°C] ValueY': 'panel6', 'Panel hőfok 8 [°C] ValueY': 'panel8',
                                                        'Panel hőfok 9 [°C] ValueY': 'panel9', 'Panel hőfok 10 [°C] ValueY': 'panel10',
                                                        'Panel hőfok 11 [°C] ValueY': 'panel11', 'Panel hőfok 12 [°C] ValueY': 'panel12',
                                                        'Panel hőfok 13 [°C] ValueY': 'panel13', 'Panel hőfok 14 [°C] ValueY': 'panel14',
                                                        'Panel hőfok 15 [°C] ValueY': 'panel15'})
    renamed_panelek = renamed_panelek.apply(replace_dot)
    return renamed_panelek

def db_connect(adag_data, panel_data):
    create_adagok = "CREATE TABLE adagok (adagszam int PRIMARY KEY, kezdet Datetime, vege Datetime);"
    create_panelek = """CREATE TABLE panelek (id INT IDENTITY(1, 1) PRIMARY KEY, time Datetime, panel1 float, panel2 float, panel3 float, 
    panel4 float, panel5 float, panel6 float, panel8 float, panel9 float, panel10 float, panel11 float, panel12 float,
    panel13 float, panel14 float, panel15 float);"""
    insert_panelek = """INSERT INTO dbo.panelek (time, panel1, panel2, panel3, panel4, panel5, panel6, panel8, 
    panel9, panel10, panel11, panel12, panel13, panel14, panel15) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"""
    load_dotenv()
    conn = mssql.connect(os.getenv("SQL_CONN_LOCAL"))
    cursor = conn.cursor()
    cursor.execute(create_adagok)
    print("Adagok tábla elkészítve")
    cursor.commit()
    for index, row in adag_data.iterrows():
        cursor.execute("INSERT INTO dbo.adagok (adagszam, kezdet, vege) values(?,?,?)", row.adagszam, row.kezdet, row.vege)
    print("Adagok feltöltve")
    cursor.commit()
    cursor.execute(create_panelek)
    print("Panelek tábla elkészítve")
    cursor.commit()
    counter = 1
    for index, row in panel_data.iterrows():
        print(f"Uploading {counter}")
        cursor.execute(insert_panelek,
              row.time, row.panel1, row.panel2, row.panel3, row.panel4, row.panel5, row.panel6, row.panel8, row.panel9, row.panel10, row.panel11,
              row.panel12, row.panel13, row.panel14, row.panel15)
        counter = counter + 1
    cursor.commit()
    cursor.close()

def test():
    panelek_df = pd.read_csv("Hűtőpanelek.csv", delimiter=";")
    #Header list
    headers = list(panelek_df.columns.values)
    print(panelek_df['Panel hőfok 11 [°C] ValueY'])
  
db_connect(load_adag_data(), load_panel_data())
