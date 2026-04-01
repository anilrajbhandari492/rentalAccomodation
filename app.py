from flask import Flask, render_template, request, redirect, session, send_from_directory
import sqlite3
import os
import re
from werkzeug.utils import secure_filename
from config import Config

app = Flask(__name__)
app.config.from_object(Config)


# =========================================================
# ANIL - DATABASE + SECURITY + ADMIN + CORE
# =========================================================

# DATABASE
def get_db():
    conn = sqlite3.connect(Config.DATABASE)
    conn.row_factory = sqlite3.Row
    return conn




