import requests
# Insert your pipeline token here
TOKEN = "g8XxpbvgGwgHda2AXV6NRh"
# This function helps you with uploading a file which is stored on your computer locally
def upload_via_presigned_url():
    r = requests.post("https://api2.dropbase.io/v1/pipeline/generate_presigned_url", data={'token': TOKEN})
    if(r.status_code != 200): # Something failed
        print(r.status_code)
        print(r.json()) # Detailed error message
    presigned_url = r.json()["upload_url"] # Link to upload a file
    job_id = r.json()["job_id"] # Job_id to see the status of the pipeline once the file is uploaded
    # Now we upload the file
    r = requests.put(presigned_url, data=open('GZmSggoLctM9sVj59NxoPb.csv', 'rb'))
    if(r.status_code != 200): # Failed to upload and run pipeline
        print(r.status_code)
        print(r.json())
    # The pipeline will now run
    return job_id
# This function helps with getting the status of the job
def get_status(job_id):
    r = requests.get("https://api.dropbase.io/v1/pipeline/run_pipeline", data={'token': TOKEN})
    while(r.status_code == 202):
        print(r.json()) # Prints the message of what is happening
        time.sleep(1)
        r = requests.get("https://api2.dropbase.io/v1/pipeline/run_pipeline", data={'token': TOKEN})
    if(r.status_code != 200):
        print("There is an error")
        print(r.status_code)
        print(r.json())
    else:
        print("Successful!")
print(get_status("JtnjoQtmZvNsgkxxTrLEPj"))