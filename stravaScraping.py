from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.action_chains import ActionChains
import time
from scraping_secrets import pwd
from scraping_secrets import email
import pandas as pd


driver = webdriver.Edge()

#last crashed at first pro, jan 26

pros = [189040,254096,465035,2119306,1189566,384548,1630132,9232885,1905161,186522,8758,4097457,5060232,3979847,5201565,2192184,197359,8203181,2926114,6782552,19593505,30579397,2905866,34780520,4671192,1751647,1936233,320095,2041772,119832,3645709,74997,20067483,3813861,192085,1579951,119155,174573,11668,188840]

months = [202308,202309,202310,202311,202312,202401]

driver.get('https://www.strava.com/login')

driver.find_element(By.NAME, "email").send_keys(email)

driver.find_element(By.NAME,'password').send_keys(pwd)

driver.find_element(By.NAME,'remember_me').click()

driver.find_element(By.ID,'login-button').click()

df = pd.DataFrame(columns = ['ID','Date', 'Mileage', 'Activity-Type', 'Time', 'Location'])

for pro in pros:

    for interval in months:

        nextlink = f'https://www.strava.com/pros/{pro}#interval?interval={interval}&interval_type=month&chart_type=miles&year_offset=0'

        driver.get(nextlink)

        time.sleep(20)

        elements = driver.find_elements(By.CSS_SELECTOR, '[data-testid="map"]')

        for i in elements:

            ActionChains(driver) \
                .key_down(Keys.CONTROL) \
                .click(i) \
                .key_up(Keys.CONTROL) \
                .perform()
            
            time.sleep(1)

            p = driver.current_window_handle

            chwd = driver.window_handles

            for w in chwd:
                if(w!=p):
                    driver.switch_to.window(w)

            time.sleep(2)

            driver.find_element(By.ID,'gpx-download').click()

            date = driver.find_element(By.XPATH, '//*[@id="heading"]/div/div/div[1]/div[1]/div/time')
            
            miles = driver.find_element(By.XPATH, '//*[@id="heading"]/div/div/div[2]/ul[1]/li[1]/strong')

            activity_type = driver.find_element(By.XPATH, '//*[@id="heading"]/header/h2/span')

            activity_time = driver.find_element(By.XPATH, '//*[@id="heading"]/div/div/div[2]/ul[1]/li[2]/strong')

            location = driver.find_element(By.XPATH, '//*[@id="heading"]/div/div/div[1]/div[1]/div/span')

            new_row = {'ID':pro,'Date':date.text, 'Mileage':miles.text, 'Activity-Type':activity_type.text, 'Time':activity_time.text, 'Location':location.text}

            df = df._append(new_row, ignore_index=True)

            driver.close()

            driver.switch_to.window(driver.window_handles[0])


input()









