cat > notebooks/hide_mysql_password_notes.md << 'EOF'
# How to Hide MySQL Password in Streamlit

lianes_library_app/
│
├── .streamlit/
│   └── secrets.toml
│
├── src/
│   └── app.py
│
└── notebooks/
    └── hide_mysql_password_notes.md

-- Do not write the real MySQL password directly inside `app.py`.
-- The .streamlit folder must be in the project root, not inside src.


Step 1: Create the secrets file
From the project root:
mkdir -p .streamlit
printf '[mysql]\npassword = "YOUR_MYSQL_PASSWORD"\n' > .streamlit/secrets.toml
Replace YOUR_MYSQL_PASSWORD with the real MySQL password.

Step 2: Use the password in app.py
import streamlit as st
from sqlalchemy import create_engine
from urllib.parse import quote_plus

schema = "liane_library"
host = "127.0.0.1"
user = "root"
password = quote_plus(st.secrets["mysql"]["password"])
port = 3306

connection_string = f"mysql+pymysql://{user}:{password}@{host}:{port}/{schema}"
engine = create_engine(connection_string)

Step 3: Run the app from the project root
cd ~/Documents/projects/lianes_library_app
conda activate lianes_lib_env
streamlit run src/app.py


To view the content/password:
cat .streamlit/secrets.toml
