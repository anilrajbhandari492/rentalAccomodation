<<<<<<< HEAD

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

# PASSWORD VALIDATION
def is_strong_password(password):
    return (
        len(password) >= 6 and
        re.search(r"[A-Za-z]", password) and
        re.search(r"[0-9]", password)
    )


# MEDIA ROUTES
@app.route('/images/<filename>')
def images(filename):
    return send_from_directory(Config.IMAGE_UPLOAD, filename)


@app.route('/profile-images/<filename>')
def profile_images(filename):
    return send_from_directory(Config.PROFILE_UPLOAD, filename)


# REGISTER
@app.route("/register", methods=["GET","POST"])
def register():

    if request.method == "POST":

        name = request.form.get("full_name")
        email = request.form.get("email")
        password = request.form.get("password")
        phone = request.form.get("phone")

        if not is_strong_password(password):
            return render_template("register.html", message="Weak password")

        profile_pic = request.files.get("profile_pic")

        pic_name = ""
        if profile_pic and profile_pic.filename:
            pic_name = secure_filename(profile_pic.filename)
            profile_pic.save(os.path.join(Config.PROFILE_UPLOAD, pic_name))

        conn = get_db()

        conn.execute("""
        INSERT INTO users(full_name,email,password_hash,role,phone,profile_pic)
        VALUES (?,?,?,?,?,?)
        """,(name,email,password,"owner",phone,pic_name))

        conn.commit()
        conn.close()

        return redirect("/login")

    return render_template("register.html")


# LOGIN
@app.route("/login", methods=["GET","POST"])
def login():

    if request.method == "POST":

        email = request.form.get("email")
        password = request.form.get("password")

        conn = get_db()
        user = conn.execute("SELECT * FROM users WHERE email=?",(email,)).fetchone()
        conn.close()

        if user and user["password_hash"] == password:
            session["user_id"] = user["user_id"]
            session["role"] = user["role"]

            if user["role"] == "admin":
                return redirect("/admin")
            elif user["role"] == "tenant":
                return redirect("/tenant")
            else:
                return redirect("/owner")

        return render_template("login.html", message="Invalid credentials")

    return render_template("login.html")


# ADMIN DASHBOARD
@app.route("/admin")
def admin_dashboard():
    conn = get_db()
    users = conn.execute("SELECT * FROM users").fetchall()
    conn.close()
    return render_template("admin-dashboard.html", users=users)





# VISIT REQUEST
@app.route("/visit/<int:property_id>", methods=["GET","POST"])
def visit_request(property_id):
    if request.method == "POST":
        return redirect("/tenant")
    return render_template("visit-request.html")
