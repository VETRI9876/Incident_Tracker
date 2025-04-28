import streamlit as st
import pandas as pd
import plotly.express as px
from datetime import datetime
import os
import boto3
from io import StringIO

# Constants
S3_BUCKET_NAME = 'vetri-devops-bucket'
S3_FILE_KEY = 'incident_data.csv'
DATE_FORMAT = "%Y-%m-%d %H:%M:%S"

# Initialize S3 client
s3_client = boto3.client('s3', region_name='eu-north-1')

# Load data from S3
def load_data():
    """Load existing incident data from S3 or create an empty DataFrame if none exists."""
    try:
        s3_response = s3_client.get_object(Bucket=S3_BUCKET_NAME, Key=S3_FILE_KEY)
        data = s3_response['Body'].read().decode('utf-8')
        return pd.read_csv(StringIO(data), parse_dates=["Date"])
    except s3_client.exceptions.NoSuchKey:
        # Return an empty DataFrame if the file doesn't exist
        return pd.DataFrame(columns=["System", "Incident Type", "Resolution Time (mins)", "Severity", "Root Cause", "Date"])

# Save data to S3
def save_data(df):
    """Save the DataFrame to S3."""
    csv_buffer = StringIO()
    df.to_csv(csv_buffer, index=False)
    s3_client.put_object(Bucket=S3_BUCKET_NAME, Key=S3_FILE_KEY, Body=csv_buffer.getvalue())

# Append new incident entry to the DataFrame
def log_incident(df, system, incident_type, resolution_time, severity, root_cause):
    """Log a new incident entry and return the updated DataFrame."""
    new_entry = {
        "System": system,
        "Incident Type": incident_type,
        "Resolution Time (mins)": resolution_time,
        "Severity": severity,
        "Root Cause": root_cause,
        "Date": datetime.now().strftime(DATE_FORMAT)
    }
    return pd.concat([df, pd.DataFrame([new_entry])], ignore_index=True)

# Plot MTTR trend over time
def plot_mttr(df):
    """Plot the Mean Time To Repair (MTTR) trend over time."""
    df['Day'] = pd.to_datetime(df['Date']).dt.date
    mttr = df.groupby('Day')["Resolution Time (mins)"].mean().reset_index()
    fig = px.line(mttr, x="Day", y="Resolution Time (mins)", title="📈 MTTR Over Time", markers=True)
    fig.update_layout(template='plotly_white', xaxis_title="Date", yaxis_title="Average Resolution Time (mins)")
    st.plotly_chart(fig, use_container_width=True)

# Plot severity distribution in a pie chart
def plot_severity_distribution(df):
    """Plot incident distribution by severity as a pie chart."""
    severity_counts = df["Severity"].value_counts().reset_index()
    severity_counts.columns = ["Severity", "Count"]
    fig = px.pie(severity_counts, values='Count', names='Severity', title="📊 Incident Distribution by Severity",
                 color_discrete_sequence=px.colors.qualitative.Safe)
    fig.update_layout(template='plotly_white')
    st.plotly_chart(fig, use_container_width=True)

# Main application logic
def main():
    st.set_page_config(page_title="Incident Tracker", layout="wide")
    st.title("🚨 Incident Response Tracker")

    df = load_data()

    # Log a new incident
    with st.expander("📝 Log a New Incident", expanded=True):
        with st.form("incident_form"):
            cols = st.columns(2)
            system = cols[0].text_input("🔧 System Affected")
            incident_type = cols[1].text_input("💥 Incident Type")
            resolution_time = cols[0].number_input("⏱️ Resolution Time (mins)", min_value=1)
            severity = cols[1].selectbox("⚠️ Severity", ["Low", "Medium", "High", "Critical"])
            root_cause = st.text_area("📌 Root Cause")
            submitted = st.form_submit_button("✅ Submit Incident")

            if submitted:
                if system and incident_type and root_cause:
                    df = log_incident(df, system, incident_type, resolution_time, severity, root_cause)
                    save_data(df)
                    st.success("Incident logged successfully.")
                else:
                    st.error("Please complete all required fields.")

    # Display analytics if data exists
    if not df.empty:
        st.markdown("---")
        st.subheader("📉 Incident Analytics Dashboard")
        col1, col2 = st.columns(2)
        with col1:
            plot_mttr(df)
        with col2:
            plot_severity_distribution(df)

        st.markdown("---")
        st.subheader("📋 Complete Incident Log")
        with st.expander("🔍 View Table", expanded=True):
            st.dataframe(df.sort_values(by="Date", ascending=False), use_container_width=True)

if __name__ == "__main__":
    main()
