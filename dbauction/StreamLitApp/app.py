# import librairies
import os
import openai
import streamlit as st
import mysql.connector

# Configure OpenAI API key securely via environment or Streamlit secrets
_api_key = os.getenv("OPENAI_API_KEY")
if not _api_key:
    try:
        _api_key = st.secrets["OPENAI_API_KEY"]
    except Exception:
        _api_key = None

if not _api_key:
    st.warning(
        "OPENAI_API_KEY is not configured. Set it as an environment variable or in .streamlit/secrets.toml.")
else:
    openai.api_key = _api_key

def _get_secret(key: str):
    """Fetch a secret from env, then Streamlit secrets.
    Supports both top-level keys and [mysql] section mapping.
    """
    val = os.getenv(key)
    if val:
        return val
    # direct top-level access
    try:
        return st.secrets[key]
    except Exception:
        pass
    # [mysql] section fallback for DB_* keys
    try:
        mapping = {
            'DB_HOST': 'host',
            'DB_NAME': 'name',
            'DB_USER': 'user',
            'DB_PASSWORD': 'password',
            'DB_PORT': 'port',
        }
        if key in mapping and 'mysql' in st.secrets:
            return st.secrets['mysql'].get(mapping[key])
    except Exception:
        pass
    return None

# Database configuration via environment variables or Streamlit secrets
DB_HOST = _get_secret("DB_HOST")
DB_NAME = _get_secret("DB_NAME")
DB_USER = _get_secret("DB_USER")
DB_PASSWORD = _get_secret("DB_PASSWORD")
DB_PORT = _get_secret("DB_PORT") or 3306

SQL_CONNECTION = None
if all([DB_HOST, DB_NAME, DB_USER, DB_PASSWORD]):
    try:
        SQL_CONNECTION = mysql.connector.connect(
            host=DB_HOST,
            user=DB_USER,
            password=DB_PASSWORD,
            database=DB_NAME,
            port=int(DB_PORT) if isinstance(DB_PORT, str) else DB_PORT,
        )
    except Exception as e:
        st.error(f"Failed to connect to MySQL: {e}")
else:
    st.warning("Database credentials (DB_HOST, DB_NAME, DB_USER, DB_PASSWORD) are not fully configured.")

# Text input where the user enter the text to be translated to SQL query
query = st.text_input('Enter you text to generate SQL query', '')

# The query is sent to the OpenAI API  throught the prompt variable using
# the "text-davinci-002" engine, and the generated response is returned as
# a string.
# These  parameters configuration where based on the ones provided by openai


def generate_sql(query):
    model_engine = "text-davinci-002"
    prompt = f"""
        Given the following SQL tables, your job is to write queries given a user’s request.
        CREATE TABLE dbapp_user (
            id INT AUTO_INCREMENT PRIMARY KEY,
            password VARCHAR(128) NOT NULL,
            last_login DATETIME(6) NULL,
            is_superuser BOOLEAN NOT NULL,
            username VARCHAR(150) NOT NULL UNIQUE,
            first_name VARCHAR(30) NOT NULL,
            last_name VARCHAR(150) NOT NULL,
            email VARCHAR(254) NOT NULL,
            is_staff BOOLEAN NOT NULL,
            is_active BOOLEAN NOT NULL,
            date_joined DATETIME(6) NOT NULL
        );

        CREATE TABLE dbapp_category (
            id INT AUTO_INCREMENT PRIMARY KEY,
            title VARCHAR(64) NOT NULL
        );
        
        CREATE TABLE dbapp_auction (
            id INT AUTO_INCREMENT PRIMARY KEY,
            title VARCHAR(64) NOT NULL,
            description TEXT NOT NULL,
            starting_bid DECIMAL(9,2) DEFAULT 0.00 NOT NULL,
            current_bid DECIMAL(9,2) DEFAULT 0.00 NOT NULL,
            category_id INT NULL,
            imageURL VARCHAR(2048) NULL,
            seller_id INT NOT NULL,
            closed BOOLEAN NOT NULL DEFAULT FALSE,
            creation_date DATETIME(6) NOT NULL,
            update_date DATETIME(6) NULL,
            FOREIGN KEY (category_id) REFERENCES dbapp_category(id),
            FOREIGN KEY (seller_id) REFERENCES dbapp_user(id)
        );


        CREATE TABLE dbapp_bid (
            id INT AUTO_INCREMENT PRIMARY KEY,
            bider_id INT NOT NULL,
            bid_date DATETIME(6) NOT NULL,
            bid_price DECIMAL(9,2) NOT NULL,
            auction_id INT NOT NULL,
            FOREIGN KEY (bider_id) REFERENCES dbapp_user(id),
            FOREIGN KEY (auction_id) REFERENCES dbapp_auction(id)
        );

        CREATE TABLE dbapp_comment (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT NOT NULL,
            headline VARCHAR(64) NOT NULL,
            message TEXT NOT NULL,
            cm_date DATETIME(6) NOT NULL,
            auction_id INT NOT NULL,
            FOREIGN KEY (user_id) REFERENCES dbapp_user(id),
            FOREIGN KEY (auction_id) REFERENCES dbapp_auction(id)
        );

        CREATE TABLE dbapp_watchlist (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT NOT NULL UNIQUE,
            FOREIGN KEY (user_id) REFERENCES dbapp_user(id)
        );

        CREATE TABLE dbapp_watchlist_auctions (
            watchlist_id INT NOT NULL,
            auction_id INT NOT NULL,
            PRIMARY KEY (watchlist_id, auction_id),
            FOREIGN KEY (watchlist_id) REFERENCES dbapp_watchlist(id),
            FOREIGN KEY (auction_id) REFERENCES dbapp_auction(id)
        );
        User's request: "{query}"
        SQL Query:
    """
    response = openai.Completion.create(
        engine=model_engine,
        prompt=prompt,
        temperature=0,
        max_tokens=150,
        top_p=1.0,
        frequency_penalty=0.0,
        presence_penalty=0.0,
        stop=["#", ";"]
    )
    # Format the SQL query for better readability
    formatted_sql = response.choices[0].text.strip()
    formatted_sql = formatted_sql.replace("\\n", "\n").replace("\\t", "\t")
    return formatted_sql


def display_results(results):
    # Check if results have multiple columns
    if results and isinstance(results[0], tuple):
        for row in results:
            # Unpack the tuple and display each value
            st.write(' | '.join(map(str, row)))
    else:
        for value in results:
            # If it's not a tuple, just write the value
            st.write(value)


# if the Generate SQL query if clicked
if st.button('Generate SQL query'):
    if not _api_key:
        st.error('OpenAI API key is not configured.')
    elif SQL_CONNECTION is None:
        st.error('Database connection is not configured.')
    elif query:  # Checking if the query string is not empty
        response = generate_sql(query)
        st.code(response, language='sql')  # Display the generated SQL query

        with SQL_CONNECTION.cursor() as cursor:
            try:
                cursor.execute(response)  # Execute the SQL query
                results = cursor.fetchall()  # Fetch all the results
                if results:
                    st.write('Result After running Query on Database')
                    # Display the results using the updated function
                    display_results(results)
                else:
                    st.write("No Record Found")
            except (mysql.connector.Error, mysql.connector.Warning) as e:
                st.write(f'Error: {e}')
            finally:
                SQL_CONNECTION.close()
