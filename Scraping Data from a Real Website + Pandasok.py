#!/usr/bin/env python
# coding: utf-8

# In[1]:


#Import libraries
from bs4 import BeautifulSoup
import requests

import pandas as pd


# In[2]:


#Website
url = 'https://en.wikipedia.org/wiki/List_of_largest_companies_in_the_United_States_by_revenue'

page = requests.get(url)

soup = BeautifulSoup(page.text, 'html')


# In[3]:


print(soup)


# In[4]:


#Looking for table
soup.find('table')


# In[5]:


soup.find_all('table')[1]


# In[6]:


soup.find('table', class_ = 'wikitable sortable')


# In[7]:


table = soup.find_all('table')[1]


# In[8]:


print(table)


# In[9]:


world_titles = table.find_all('th')


# In[10]:


world_titles


# In[11]:


#Define Headers of columns
world_table_titles = [title.text.strip() for title in world_titles]

print(world_table_titles)


# In[12]:


#Display the table
df = pd.DataFrame(columns = world_table_titles)
df


# In[13]:


column_data = table.find_all('tr')


# In[14]:


#Complete with row information
for row in column_data[1:]:
    row_data = row.find_all('td')
    individual_row_data = [data.text.strip() for data in row_data]
        
    lenght= len(df)
    df.loc[lenght] = individual_row_data


# In[15]:


#View complete table
df


# In[18]:


#Export Table in csv format and delete index column
df.to_csv(r'C:\Users\alexa\SQLTutorial\AlexTutorial\Python\WebScraping\CompaniesRank.csv', index = False)


# In[ ]:




