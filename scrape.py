import time
import datetime
from bs4 import BeautifulSoup
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import Select
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
import pandas as pd
from webdriver_manager.chrome import ChromeDriverManager
from webdriver_manager.core.os_manager import ChromeType

index = [1, 2, 3, 4, 6, 7, 8]
#index = [2]

for i in index:

    #Adjusting the code according to GitHub webdriver requirements.
    chrome_service = Service(ChromeDriverManager(chrome_type=ChromeType.CHROMIUM).install())
    
    chrome_options = Options()
    options = [
        "--headless",
        "--disable-gpu",
        "--window-size=1920,1200",
        "--ignore-certificate-errors",
        "--disable-extensions",
        "--no-sandbox",
        "--disable-dev-shm-usage"
    ]
    for option in options:
        chrome_options.add_argument(option)
    
    
    ########## Setting up the scraping environment ##########

    try:

        # Specify the URL of the website
        url = "https://holtankoljak.hu/station_result#tartalom"

        # Initialize a web driver (replace 'chromedriver.exe' with the path to your WebDriver)
        driver = webdriver.Chrome(service=chrome_service, options=chrome_options)
        # Open the website in the browser
        driver.get(url)

        #Sleeping for 2 sec until the driver and agreement renders. (At least it works.)
        time.sleep(2)

        #Elfogadom az adatvédelmet xd
        elfogadok = driver.find_element(By.CSS_SELECTOR, "div.qc-cmp2-summary-buttons")
        elfogad = elfogadok.find_element(By.CSS_SELECTOR, "button:nth-of-type("+str(2)+")")
        elfogad.click()

        #Selecting fuel type by value from 1-8
        dropdown = driver.find_element(By.CSS_SELECTOR, "select#uatip.form-select")
        select = Select(dropdown)

        # Using fuel numbers by index in dropdown list(1, 2, 3, 4, 6, 7, 8)
        selected_fuel = i
        select.select_by_value(str(selected_fuel))

        #Adding the location
        locations = driver.find_element(By.CSS_SELECTOR, "div#holvan.btn-group.mt-1")
        location_button = locations.find_element(By.CSS_SELECTOR, "button:nth-of-type("+str(3)+")")
        location_button.click()

        fill_element = driver.find_element(By.CSS_SELECTOR, "input#irsz.form-control")
        fill_element.send_keys("Budapest VIII")

        #Ezek talán nem kellenek.
        #offer = driver.find_element(By.CSS_SELECTOR, "link_none2.text-xs")
        #offer.click()

        #Setting the slider maximum value and selected value
        slider = driver.find_element(By.CSS_SELECTOR, "input#distance.slider")
        driver.execute_script("arguments[0].setAttribute('max', '500')", slider)
        driver.execute_script("arguments[0].setAttribute('value', '500')", slider)

        #Sleeping for 2 sec so that the system can accommodate attribute configuration. (Wow, it works again.)
        time.sleep(2)

        #Searching for the results
        search = driver.find_element(By.CSS_SELECTOR, "button.btn.btn-outline-success.rounded-5.text-uppercase")
        search.click()

        ########## Start scrping the page ##########

        results = driver.find_element(By.CSS_SELECTOR, "div.lapcim2.text-uppercase.fs-2")
        text_content = results.get_attribute("textContent")

        if selected_fuel == 1:
            num_of_res = int(text_content[51:-8])
        elif selected_fuel == 2:
            num_of_res = int(text_content[42:-8])
        elif selected_fuel == 3:
            num_of_res = int(text_content[38:-8])
        elif selected_fuel == 4:
            num_of_res = int(text_content[51:-8])
        elif selected_fuel == 6:
            num_of_res = int(text_content[50:-8])
        elif selected_fuel == 7:
            num_of_res = int(text_content[53:-8])
        elif selected_fuel == 8:
            num_of_res = int(text_content[51:-8])

        #Saving both location and price values
        results = driver.find_element(By.CSS_SELECTOR, "div#results.mb-5")
        text_content = results.get_attribute("textContent")
        #The counter counts how many times the location and price extraction happened
        counter = 0

        location_list = []
        price_list = []



        while counter < num_of_res - 1:
            #Creating the station section, cutting down the begining and the end
            text_begin = "\n\t\t\n\t\t\t\n\t\t\t\t\n\t\t\t\n\t\t\t\n\t\t\t\n\t\t\t\t\n\t\t\t\t\t\t\n\t\t\t\t\t\tJelenlegi pozíciótól: "
            text_new = text_content[len(text_begin):]
            text_end_nem_akcio = " / liter\n\t\t\t\t\t\n\t\t\t\t\n\t\t\t\n\t\t\t\n\t\t\t\t\n\t\t\t\t\t\n\t\t\t\t\n\t\t\t\n\t\t\n\t\t\n\t\t\t\n\t\t\t\t\n\t\t\t\n\t\t\t\n\t\t\t\n\t\t\t\t\n\t\t\t\t\t\t\n\t\t\t\t\t\t"
            text_end_akcio = " / liter\n\t\t\t\t\t\n\t\t\t\t\n\t\t\t\n\t\t\t\n\t\t\t\tAKCIÓ\n\t\t\t\t\t\n\t\t\t\t\n\t\t\t\n\t\t\n\t\t\n\t\t\t\n\t\t\t\t\n\t\t\t\n\t\t\t\n\t\t\t\n\t\t\t\t\n\t\t\t\t\t\t\n\t\t\t\t\t\t"
            try:
                akcio = text_content.index(text_end_akcio)
            except ValueError:
                akcio = 9999999999
            if text_content.index(text_end_nem_akcio) < akcio:
                end_position = text_new.index(text_end_nem_akcio)
            else :
                end_position = text_new.index(text_end_akcio)
            text_new = text_new[:end_position]
            text_new

            #Cutting additional string from the begining
            before_location = "km\n\t\t\t\t\t\n\t\t\t\n\t\t\t\n\t\t\t\t\n\t\t\t\t\t\n\t\t\t\t\t\t"
            end_position = text_new.index(before_location)
            text_new = text_new[end_position + len(before_location):]
            text_new

            #Cutting middle string and creating new location and new price observations
            middle_string = "\n\t\t\t\t\t\n\t\t\t\n\t\t\t\n\t\t\t\t\n\t\t\t\t\t"
            end_position = text_new.index(middle_string)
            location_new = text_new[:end_position]
            price_new = float(text_new[end_position + len(middle_string):])
            location_list.append(location_new)
            price_list.append(price_new)

            #Cutting the new global string.
            #text_content = text_content[1:]
            try:
                akcio = text_content.index(text_end_akcio)
            except ValueError:
                akcio = 9999999999
            if text_content.index(text_end_nem_akcio) < akcio:
                end_position = text_content.index(text_end_nem_akcio)
            else :
                end_position = text_content.index(text_end_akcio)
            text_content = text_content[end_position + 1:]
            #text_content

            #Setting the counter one higher
            counter += 1
            counter

        #Creating the last observation with a slight modification
        #Creating the station section, cutting down the begining and the end
        text_begin = "\n\t\t\n\t\t\t\n\t\t\t\t\n\t\t\t\n\t\t\t\n\t\t\t\n\t\t\t\t\n\t\t\t\t\t\t\n\t\t\t\t\t\tJelenlegi pozíciótól: "
        text_new = text_content[len(text_begin):]
        text_end_nem_akcio = " / liter\n\t\t\t\t\t\n\t\t\t\t\n\t\t\t\n\t\t\t\n\t\t\t\t\n\t\t\t\t\t\n\t\t\t\t\n\t\t\t\n\t\t\n\t"
        text_end_akcio = " / liter\n\t\t\t\t\t\n\t\t\t\t\n\t\t\t\n\t\t\t\n\t\t\t\tAKCIÓ\n\t\t\t\t\t\n\t\t\t\t\n\t\t\t\n\t\t\n\t"
        try:
            akcio = text_content.index(text_end_akcio)
        except ValueError:
            akcio = 9999999999
        if text_content.index(text_end_nem_akcio) < akcio:
            end_position = text_new.index(text_end_nem_akcio)
        else :
            end_position = text_new.index(text_end_akcio)
        text_new = text_new[:end_position]
        text_new

        #Cutting additional string from the begining
        before_location = "km\n\t\t\t\t\t\n\t\t\t\n\t\t\t\n\t\t\t\t\n\t\t\t\t\t\n\t\t\t\t\t\t"
        end_position = text_new.index(before_location)
        text_new = text_new[end_position + len(before_location):]
        text_new

        #Cutting middle string and creating new location and new price observations
        middle_string = "\n\t\t\t\t\t\n\t\t\t\n\t\t\t\n\t\t\t\t\n\t\t\t\t\t"
        end_position = text_new.index(middle_string)
        location_new = text_new[:end_position]
        price_new = float(text_new[end_position + len(middle_string):])
        location_list.append(location_new)
        price_list.append(price_new)

        #Cutting the new global string.
        #text_content = text_content[1:]
        try:
            akcio = text_content.index(text_end_akcio)
        except ValueError:
            akcio = 9999999999
        if text_content.index(text_end_nem_akcio) < akcio:
            end_position = text_content.index(text_end_nem_akcio)
        else :
            end_position = text_content.index(text_end_akcio)
        text_content = text_content[end_position + 1:]
        #text_content

        #Setting the counter one higher
        counter += 1
        #counter should be equal to num_of_res
        #location_list contains the station locations in order
        #price_list contains the fuel prices in order

        #Collecting the brand elements in order.
        image_elements = driver.find_elements(By.TAG_NAME, "img")
        len(image_elements)
        #image_elements
        # Initialize a list to store the alt attributes
        alt_attributes = []

        # Loop through the image elements and extract their alt attributes
        for image_element in image_elements:
            alt_attribute = image_element.get_attribute("aria-label")
            alt_attributes.append(alt_attribute)

        # Print the extracted alt attributes
        #for alt_attribute in alt_attributes:
        #    print("Image Label (aria-label):", alt_attribute)

        len(alt_attributes)

        alt_attributes = alt_attributes[0:2*num_of_res]
        len(alt_attributes)
        alt_attributes

        brands = []
        for i in range(2 * num_of_res):
            if i % 2 == 1:
                brands.append(alt_attributes[i])

        # brands represents the list of brands in order.

        #Getting the current date.

        current_date = datetime.date.today()
        #current_date represents the system date

        current_date_list = []    
        a = 0
        while a < num_of_res:
            current_date_list.append(str(current_date))
            a += 1

        #current_date_list represents the list of identical fuel values

        #Attachning a fuel type list

        #Getting fuel string
        if selected_fuel == 1:
            fuel_type = "95 octane petrol"
        elif selected_fuel == 2:
            fuel_type = "diesel"
        elif selected_fuel == 3:
            fuel_type = "lpg"
        elif selected_fuel == 4:
            fuel_type = "100 octane petrol"
        elif selected_fuel == 6:
            fuel_type = "premium diesel"
        elif selected_fuel == 7:
            fuel_type = "premium octane petrol"
        elif selected_fuel == 8:
            fuel_type = "98 octane petrol"

        fuel_list = []    
        a = 0
        while a < num_of_res:
            fuel_list.append(fuel_type)
            a += 1

        #fuel_list represents the list of identical fuel values

        ########## Creating the datatables ##########

        #Listing the lists to merge

        #brands represents the list of brands in order.
        #price_list contains the fuel prices in order
        #location_list contains the station locations in order.
        #current_date_list represents the list of identical fuel values
        #fuel_list represents the list of identical fuel values


        # Create a dataframe from the lists
        data = {'brand': brands, 'price': price_list, 'location': location_list, 'date': current_date_list, 'petrol': fuel_list}
        df = pd.DataFrame(data)

        # Print the resulting DataFrame
        #print(df)

        #Creating dataframe name to save

        #Getting fuel tag
        if selected_fuel == 1:
            fuel_name_to_save = "95_octane_petrol_"
        elif selected_fuel == 2:
            fuel_name_to_save = "diesel_"
        elif selected_fuel == 3:
            fuel_name_to_save = "lpg_"
        elif selected_fuel == 4:
            fuel_name_to_save = "100_octane_petrol_"
        elif selected_fuel == 6:
            fuel_name_to_save = "premium_diesel_"
        elif selected_fuel == 7:
            fuel_name_to_save = "premium_octane_petrol_"
        elif selected_fuel == 8:
            fuel_name_to_save = "98_octane_petrol_"

        today = str(current_date)

        folder_path = 'D:/BCE/[!!!]Mesterszak/scraping petrol prices/data'
        file_name = fuel_name_to_save + today + '.csv'
        # Using full_file_path when code run outside of GitHub action
        #full_file_path = f"{folder_path}/{file_name}"
        # Using github_path when code run inside GitHub action
        github_path = f"{'data/'}{file_name}"
        
        # Save the DataFrame to a CSV file in the specified folder
        df.to_csv(github_path, index=False) 
        
    except Exception as e:
        print("An exception occurred:", e)
        
#if len(df) < 2:
#    raise ValueError("DataTable length is less than 10")

# Close the WebDriver
driver.quit()
