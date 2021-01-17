import requests
# Insert your pipeline token here
TOKEN = "3wZxVkPsYpvLQdwZFM3xEx"
# This function helps with getting the status of the job

def get_status(job_id):
    # Call the server to get the status
    r = requests.get("https://api2.dropbase.io/v1/pipeline/run_pipeline", data={ "job_id":job_id })
    
    # Keep pinging the server until the job is finished
    while(r.status_code == 202):
        print(r.json()) # Prints the message of what is happening
        time.sleep(1)
        r = requests.get("https://api2.dropbase.io/v1/pipeline/run_pipeline", data={ "job_id":job_id})

    # id statys code is not 200 nor 202, then error occured
    if(r.status_code != 200):
        print("There is an error")
        print(r.status_code)
        print(r.json())
    
    else:
        print("Successful!")
# This function helps you with uploading a file which is stored on your computer locally

def upload_file_via_presigned_url():
    # First, we need to get pre-signed url 
    r = requests.post("https://api2.dropbase.io/v1/pipeline/generate_presigned_url", data={'token': TOKEN})
    if(r.status_code != 200): # Something failed
        print(r.status_code)
        print(r.json()) # Detailed error message
    presigned_url = r.json()["upload_url"] # Link to upload a file
    job_id = r.json()["job_id"] # Job_id to see the status of the pipeline once the file is uploaded
    
    # Now we upload the file
    r = requests.put(presigned_url, data=open('filterquotes.csv', 'rb')) # replace NHkJR6qjRu8kkRSk8zHiGt.csv with your file
    if(r.status_code != 200): # Failed to upload and run pipeline
        print(r.status_code)
        print(r.json())

    # The pipeline will now run
    return job_id
# Call upload file via presigned url
presigned_url_job_id = upload_file_via_presigned_url()
# Print job ID
print(presigned_url_job_id)
get_status(presigned_url_job_id)