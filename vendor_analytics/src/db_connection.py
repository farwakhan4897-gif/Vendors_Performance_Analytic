from sqlalchemy import create_engine

def get_engine(password, user='root', host='localhost', db='vendor_analytics'):
    """Returns a SQLAlchemy engine connected to MySQL."""
    url = f'mysql+pymysql://{user}:{password}@{host}/{db}'
    return create_engine(url)