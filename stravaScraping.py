from selenium import webdriver
from selenium.webdriver.common.by import By
import time
from secrets import pwd
from secrets import email

#202348 is highest selector for now, may do 202404

driver = webdriver.Edge()

proID = 189040

interval = 202311

driver.get('https://www.strava.com/login')

element = driver.find_element(By.NAME, "email")

element.send_keys(email)

element = driver.find_element(By.NAME,'password')

element.send_keys(pwd)

element = driver.find_element(By.NAME,'remember_me')

element.click()

element = driver.find_element(By.ID,'login-button')

element.click()

nextlink = f'https://www.strava.com/pros/{proID}#interval?interval={interval}&interval_type=month&chart_type=miles&year_offset=0'

driver.get(nextlink)

#elements = driver.find_elements(By.XPATH,'//a[contains(@href,"/activities/")]')

#current_window = driver.current_window_handle

#for element in elements:
#
#   element.click()
#
#    new_window = driver.window_handles[-1]
#    driver.switch_to.window(new_window)

#    print(driver.title)

#    driver.close()


input()









