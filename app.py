# =========================================================
# SUJAN - VISIT + BOOKING + AGREEMENT (CURRENT PLACEHOLDER)
# =========================================================

# VISIT REQUEST
@app.route("/visit/<int:property_id>", methods=["GET","POST"])
def visit_request(property_id):
    if request.method == "POST":
        return redirect("/tenant")
    return render_template("visit-request.html")